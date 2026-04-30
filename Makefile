TARGET := kilo
CC := gcc
CFLAGS := -Wall -Wextra -pedantic -std=c99

all: $(TARGET)

$(TARGET): main.c
	@$(CC) main.c -o $(TARGET) $(CFLAGS)


clean:
	@rm -rf $(TARGET)
