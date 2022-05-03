# Build and test
build :; nile compile --disable-hint-validation
test  :; pytest tests/
