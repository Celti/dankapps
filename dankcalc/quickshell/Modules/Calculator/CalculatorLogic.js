.pragma library

// Helper functions for safe mathematical evaluation
function factorial(n) {
    if (n < 0 || !Number.isInteger(n)) return NaN;
    if (n > 170) return Infinity;
    let r = 1;
    for (let i = 2; i <= n; i++) r *= i;
    return r;
}

function degToRad(deg) {
    return deg * (Math.PI / 180);
}

function radToDeg(rad) {
    return rad * (180 / Math.PI);
}

function formatResult(n) {
    if (typeof n !== "number" || isNaN(n)) return "Error";
    if (!isFinite(n)) return n > 0 ? "Infinity" : "-Infinity";

    // Eliminate floating point precision errors like 0.1 + 0.2 = 0.30000000000000004
    const rounded = Math.round(n * 1e12) / 1e12;

    // Check if integer
    if (Number.isInteger(rounded)) {
        return rounded.toString();
    }

    // Format scientific if extremely large or tiny
    const abs = Math.abs(rounded);
    if ((abs >= 1e12 || (abs > 0 && abs < 1e-6))) {
        return rounded.toExponential(6).replace(/e\+?/, "e");
    }

    // Trim trailing zeros after decimal point
    let s = rounded.toFixed(10);
    s = s.replace(/\.?0+$/, "");
    return s;
}

function transformExpression(expr, isRad) {
    if (!expr) return "";

    // Close any unclosed parentheses automatically for evaluation
    const openParens = (expr.match(/\(/g) || []).length;
    const closeParens = (expr.match(/\)/g) || []).length;
    if (openParens > closeParens) {
        expr = expr + ")".repeat(openParens - closeParens);
    }

    // Replace display symbols with math equivalents
    let res = expr
        .replace(/×/g, "*")
        .replace(/÷/g, "/")
        .replace(/−/g, "-")
        .replace(/π/g, "Math.PI")
        .replace(/(?<![a-zA-Z0-9_.])e(?![a-zA-Z0-9_(])/g, "Math.E")
        .replace(/√\(/g, "Math.sqrt(")
        .replace(/\^/g, "**")
        .replace(/(\d+(\.\d+)?)!/g, "factorial($1)")
        .replace(/%/g, "*0.01");

    // Trigonometry conversions based on Rad/Deg mode
    if (isRad) {
        res = res
            .replace(/\basin\(/g, "Math.asin(")
            .replace(/\bacos\(/g, "Math.acos(")
            .replace(/\batan\(/g, "Math.atan(")
            .replace(/\bsin\(/g, "Math.sin(")
            .replace(/\bcos\(/g, "Math.cos(")
            .replace(/\btan\(/g, "Math.tan(");
    } else {
        // Degree mode
        res = res
            .replace(/\basin\(([^)]+)\)/g, "(radToDeg(Math.asin($1)))")
            .replace(/\bacos\(([^)]+)\)/g, "(radToDeg(Math.acos($1)))")
            .replace(/\batan\(([^)]+)\)/g, "(radToDeg(Math.atan($1)))")
            .replace(/\bsin\(([^)]+)\)/g, "(Math.sin(degToRad($1)))")
            .replace(/\bcos\(([^)]+)\)/g, "(Math.cos(degToRad($1)))")
            .replace(/\btan\(([^)]+)\)/g, "(Math.tan(degToRad($1)))");
    }

    // Logarithmic & exponential functions
    res = res
        .replace(/\bln\(/g, "Math.log(")
        .replace(/\blog\(/g, "Math.log10(")
        .replace(/\bexp\(/g, "Math.exp(");

    return res;
}

function evaluateExpression(expr, isRad) {
    if (!expr || expr.trim() === "") return "";

    const transformed = transformExpression(expr.trim(), isRad);

    // Guard against incomplete expressions ending in operator
    if (/[+\-*/%^.(]$/.test(expr.trim())) {
        return null;
    }

    try {
        const fn = new Function("factorial", "degToRad", "radToDeg", "Math",
            `"use strict"; return (${transformed});`
        );
        const val = fn(factorial, degToRad, radToDeg, Math);
        return formatResult(val);
    } catch (e) {
        return null;
    }
}
