
# 🧰 XCToolBox

![Static Badge](https://img.shields.io/badge/status-active-brightgreen)

This is a toolbox that contains different devex solutions for optimizing your iOS application's performance.

# Table of Contents

- [Slow Compile Detection](#slow-compile-detection)
- [Unused Image Detection](#unused-image-detection)
- [Unused Code Detection](#unused-code-detection)
- [Contribute](#contribute)

## Slow compile detection

This command uses to check for high compile-time functions and generate reports.

```bash
  iosdevex -workspace $WORKSPACE -scheme $SCHEME -warnLongFunctionBodies 200 -warnLongExpressionTypeChecking 200
```

## Unused image detection

- [FengNiao](https://github.com/onevcat/FengNiao)

## Unused code detection

- [Periphery](https://github.com/peripheryapp/periphery)

# Contribute ⚙️

If you find a bug or you would like to propose an improvement, you're welcome to create an issue.
