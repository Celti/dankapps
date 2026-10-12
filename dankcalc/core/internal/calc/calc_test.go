package calc

import (
	"testing"
)

func TestEvaluate(t *testing.T) {
	tests := []struct {
		expr     string
		isRad    bool
		expected string
	}{
		{"2 + 2", true, "4"},
		{"10 - 3 * 2", true, "4"},
		{"(10 - 3) * 2", true, "14"},
		{"10 / 4", true, "2.5"},
		{"sqrt(16)", true, "4"},
		{"sin(90)", false, "1"},
		{"cos(0)", true, "1"},
		{"fact(5)", true, "120"},
		{"2 ^ 8", true, "256"},
		{"10 % 3", true, "1"},
	}

	for _, tt := range tests {
		got, err := Evaluate(tt.expr, tt.isRad)
		if err != nil {
			t.Errorf("Evaluate(%q) error: %v", tt.expr, err)
			continue
		}
		if got != tt.expected {
			t.Errorf("Evaluate(%q) = %q; want %q", tt.expr, got, tt.expected)
		}
	}
}
