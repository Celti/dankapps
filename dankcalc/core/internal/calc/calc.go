package calc

import (
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"math"
	"strconv"
	"strings"
)

// Evaluate evaluates a mathematical expression string and returns the formatted result.
func Evaluate(expr string, isRad bool) (string, error) {
	clean := strings.TrimSpace(expr)
	if clean == "" {
		return "0", nil
	}

	// Normalize display symbols
	clean = strings.ReplaceAll(clean, "×", "*")
	clean = strings.ReplaceAll(clean, "÷", "/")
	clean = strings.ReplaceAll(clean, "−", "-")
	clean = strings.ReplaceAll(clean, "π", fmt.Sprintf("(%v)", math.Pi))
	clean = strings.ReplaceAll(clean, "e", fmt.Sprintf("(%v)", math.E))

	// Parse expression as Go AST
	node, err := parser.ParseExpr(clean)
	if err != nil {
		return "", fmt.Errorf("invalid expression: %w", err)
	}

	val, err := evalNode(node, isRad)
	if err != nil {
		return "", err
	}

	return formatValue(val), nil
}

func evalNode(node ast.Node, isRad bool) (float64, error) {
	switch n := node.(type) {
	case *ast.BasicLit:
		switch n.Kind {
		case token.INT, token.FLOAT:
			return strconv.ParseFloat(n.Value, 64)
		}
		return 0, fmt.Errorf("unsupported literal: %s", n.Value)

	case *ast.ParenExpr:
		return evalNode(n.X, isRad)

	case *ast.UnaryExpr:
		val, err := evalNode(n.X, isRad)
		if err != nil {
			return 0, err
		}
		switch n.Op {
		case token.SUB:
			return -val, nil
		case token.ADD:
			return val, nil
		}
		return 0, fmt.Errorf("unsupported unary operator: %s", n.Op)

	case *ast.BinaryExpr:
		left, err := evalNode(n.X, isRad)
		if err != nil {
			return 0, err
		}
		right, err := evalNode(n.Y, isRad)
		if err != nil {
			return 0, err
		}

		switch n.Op {
		case token.ADD:
			return left + right, nil
		case token.SUB:
			return left - right, nil
		case token.MUL:
			return left * right, nil
		case token.QUO:
			if right == 0 {
				return 0, fmt.Errorf("division by zero")
			}
			return left / right, nil
		case token.REM:
			return math.Mod(left, right), nil
		case token.XOR: // ^ as power
			return math.Pow(left, right), nil
		}
		return 0, fmt.Errorf("unsupported binary operator: %s", n.Op)

	case *ast.CallExpr:
		ident, ok := n.Fun.(*ast.Ident)
		if !ok {
			return 0, fmt.Errorf("unsupported function call")
		}
		if len(n.Args) != 1 {
			return 0, fmt.Errorf("function %s requires exactly 1 argument", ident.Name)
		}
		arg, err := evalNode(n.Args[0], isRad)
		if err != nil {
			return 0, err
		}

		switch strings.ToLower(ident.Name) {
		case "sqrt":
			return math.Sqrt(arg), nil
		case "sin":
			if !isRad {
				arg = arg * math.Pi / 180
			}
			return math.Sin(arg), nil
		case "cos":
			if !isRad {
				arg = arg * math.Pi / 180
			}
			return math.Cos(arg), nil
		case "tan":
			if !isRad {
				arg = arg * math.Pi / 180
			}
			return math.Tan(arg), nil
		case "asin":
			res := math.Asin(arg)
			if !isRad {
				res = res * 180 / math.Pi
			}
			return res, nil
		case "acos":
			res := math.Acos(arg)
			if !isRad {
				res = res * 180 / math.Pi
			}
			return res, nil
		case "atan":
			res := math.Atan(arg)
			if !isRad {
				res = res * 180 / math.Pi
			}
			return res, nil
		case "ln":
			return math.Log(arg), nil
		case "log":
			return math.Log10(arg), nil
		case "exp":
			return math.Exp(arg), nil
		case "fact":
			return factorial(arg)
		}
		return 0, fmt.Errorf("unknown function: %s", ident.Name)
	}

	return 0, fmt.Errorf("unsupported syntax node: %T", node)
}

func factorial(val float64) (float64, error) {
	if val < 0 || math.Floor(val) != val {
		return 0, fmt.Errorf("factorial requires non-negative integer")
	}
	n := int(val)
	if n > 170 {
		return math.Inf(1), nil
	}
	r := 1.0
	for i := 2; i <= n; i++ {
		r *= float64(i)
	}
	return r, nil
}

func formatValue(val float64) string {
	if math.IsNaN(val) {
		return "Error"
	}
	if math.IsInf(val, 1) {
		return "Infinity"
	}
	if math.IsInf(val, -1) {
		return "-Infinity"
	}

	// Round to 12 decimal places to remove floating noise
	rounded := math.Round(val*1e12) / 1e12
	if math.Floor(rounded) == rounded && math.Abs(rounded) < 1e15 {
		return fmt.Sprintf("%.0f", rounded)
	}

	abs := math.Abs(rounded)
	if abs >= 1e12 || (abs > 0 && abs < 1e-6) {
		return strconv.FormatFloat(rounded, 'e', 6, 64)
	}

	str := strconv.FormatFloat(rounded, 'f', 10, 64)
	str = strings.TrimRight(str, "0")
	str = strings.TrimRight(str, ".")
	return str
}
