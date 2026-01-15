# bric 🧱
A lightweight Bash-based Lambda Runtime Interface 

`bric` provides a minimal Lambda Runtime Interface implemented entirely in Bash. It’s designed for environments where simplicity, portability, and low overhead matter. 

## Dependencies 📦
The following tools and versions are known to work: 
- **GNU bash** 5.2.15(1)-release (aarch64-amazon-linux-gnu) 
- **GNU coreutils** 8.32 
- **GNU grep** 3.8 
- **curl** 8.11.1 (aarch64-amazon-linux-gnu) 

All of these are included in the container image:
```
public.ecr.aws/lambda/provided:al2023.2026.01.12.18
```

> **Note:** Only the versions listed above have been tested. Other versions may work but are not officially supported.
