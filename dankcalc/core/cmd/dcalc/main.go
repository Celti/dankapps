package main

import (
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/hthienloc/dankcalc/core/internal/calc"
	"github.com/hthienloc/dankcalc/core/internal/theme"
)

var (
	Version   = "0.1.0"
	BuildTime = "unknown"
	Commit    = "unknown"
)

func findQuickshellDir(specified string) (string, error) {
	if specified != "" {
		abs, err := filepath.Abs(specified)
		if err == nil {
			if _, err := os.Stat(filepath.Join(abs, "shell.qml")); err == nil {
				return abs, nil
			}
		}
	}

	candidates := []string{
		"quickshell",
		"../quickshell",
		"../../quickshell",
		"/usr/local/share/quickshell/dankcalc",
		"/usr/share/quickshell/dankcalc",
	}

	if home, err := os.UserHomeDir(); err == nil {
		candidates = append(candidates,
			filepath.Join(home, ".local/share/quickshell/dankcalc"),
		)
	}

	execPath, err := os.Executable()
	if err == nil {
		execDir := filepath.Dir(execPath)
		candidates = append([]string{
			filepath.Join(execDir, "../quickshell"),
			filepath.Join(execDir, "quickshell"),
			filepath.Join(execDir, "../share/quickshell/dankcalc"),
		}, candidates...)
	}

	for _, cand := range candidates {
		abs, err := filepath.Abs(cand)
		if err == nil {
			if _, err := os.Stat(filepath.Join(abs, "shell.qml")); err == nil {
				return abs, nil
			}
		}
	}

	return "", fmt.Errorf("could not locate quickshell configuration (shell.qml)")
}

func main() {
	configDir := flag.String("c", "", "path to quickshell configuration directory")
	evalExpr := flag.String("e", "", "evaluate mathematical expression and exit")
	useRad := flag.Bool("rad", true, "use radians for trigonometric functions in eval mode")
	showVersion := flag.Bool("v", false, "show version")

	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage: dcalc [options] [expression]\n\n")
		fmt.Fprintf(os.Stderr, "DankCalc - Standalone Material 3 Calculator\n\nOptions:\n")
		flag.PrintDefaults()
	}

	flag.Parse()

	if *showVersion {
		fmt.Printf("dcalc version %s (built %s, commit %s)\n", Version, BuildTime, Commit)
		return
	}

	exprToEval := *evalExpr
	if exprToEval == "" && flag.NArg() > 0 {
		// If an expression argument is passed without -e, check if it's an evaluation request
		exprToEval = flag.Arg(0)
	}

	if exprToEval != "" {
		res, err := calc.Evaluate(exprToEval, *useRad)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
		fmt.Println(res)
		return
	}

	qsDir, err := findQuickshellDir(*configDir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	env := os.Environ()
	execPath, err := os.Executable()
	if err == nil {
		env = append(env, "DCALC_BIN="+execPath)
	}

	fontCfg := theme.GetSystemFontSettings()
	if fontCfg.Family != "" {
		env = append(env, "DCALC_FONT_FAMILY="+fontCfg.Family)
	}
	if fontCfg.Scale > 0 {
		env = append(env, fmt.Sprintf("DCALC_FONT_SCALE=%.2f", fontCfg.Scale))
	}
	if fontCfg.Mono != "" {
		env = append(env, "DCALC_MONO_FONT="+fontCfg.Mono)
	}

	cmd := exec.Command("quickshell", "-p", qsDir)
	cmd.Env = env
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Error running quickshell: %v\n", err)
		os.Exit(1)
	}
}
