#!/bin/sh

swift run swift-openapi-generator generate \
	--output-directory Sources/NgrokOpenAPIClient \
	--config openapi-generator-config.yaml \
	openapi.yaml
