FROM scratch AS bash_unit
ADD https://github.com/bash-unit/bash_unit.git#v2.3.3 /tmp/bash_unit


FROM public.ecr.aws/lambda/provided:al2023.2026.01.12.18
RUN  dnf install -y diffutils 
COPY --from=bash_unit /tmp/bash_unit/bash_unit /usr/local/bin/bash_unit

