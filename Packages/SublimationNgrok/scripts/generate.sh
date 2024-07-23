#!/bin/sh

swift run swift-openapi-generator generate --output-directory Sources/Ngrokit/Generated --config openapi-generator-config.yaml openapi.yaml
