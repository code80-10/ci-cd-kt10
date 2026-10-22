CXX := g++
CXXFLAGS := -std=c++17 -Wall -Wextra -Werror

ifeq ($(OS),Windows_NT)
TARGET := build/kt10.exe
else
TARGET := build/kt10
endif

.PHONY: all clean

all: $(TARGET)

$(TARGET): src/main.cpp
	mkdir -p build
	$(CXX) $(CXXFLAGS) $< -o $@

clean:
	rm -rf build
