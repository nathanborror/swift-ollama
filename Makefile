main:
	@swift build
	@cp .build/debug/OllamaCmd ollama
	@chmod +x ollama
	@echo "Run the program with ./ollama"
