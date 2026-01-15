# Bash Lambda Runtime Interface Client
A Lambda Runtime Interface that can be used to run handler functions written in Bash in AWS Lambda

## Dependencies 
- GNU bash 5.2.15(1)-release (aarch64-amazon-linux-gnu)
- GNU coreutils 8.32
- GNU grep 3.8
- curl 8.11.1 (aarch64-amazon-linux-gnu)

All listed dependencies are available in the `public.ecr.aws/lambda/provided:al2023.2026.01.12.18` container image

*Note*: only listed versions have been tested. Other versions of dependencies have not been tested and are not supported
