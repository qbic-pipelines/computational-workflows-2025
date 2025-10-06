#!/bin/bash -euo pipefail
7z \
    a \
    -l \
     \
    "study.zip" ./inputs/*

cat <<-END_VERSIONS > versions.yml
"NFCORE_DIFFERENTIALABUNDANCE:DIFFERENTIALABUNDANCE:MAKE_REPORT_BUNDLE":
    7za: $(echo $(7za --help) | sed 's/.*p7zip Version //; s/(.*//')
END_VERSIONS
