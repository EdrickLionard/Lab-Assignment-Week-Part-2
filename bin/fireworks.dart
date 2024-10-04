import 'dart:async';
import 'dart:io';
import 'dart:math';

// ANSI escape codes for colors
const List<String> colors = [
  '\x1B[31m', // Red
  '\x1B[32m', // Green
  '\x1B[33m', // Yellow
  '\x1B[34m', // Blue
  '\x1B[35m', // Magenta
  '\x1B[36m', // Cyan
  '\x1B[37m', // White
];

// Simple background color codes (basic terminal colors)
const List<String> basicBackgroundColors = [
  '\x1B[41m', // Red background
  '\x1B[42m', // Green background
  '\x1B[43m', // Yellow background
  '\x1B[44m', // Blue background
  '\x1B[45m', // Magenta background
  '\x1B[46m', // Cyan background
  '\x1B[47m', // White background
];

const resetColor = '\x1B[0m'; // Reset to default
const hideCursor = '\x1B[?25l';
const showCursor = '\x1B[?25h';
const clearScreen = '\x1B[2J';
const boldText = '\x1B[1m';

void main() async {
  // Hide cursor and clear the screen
  stdout.write(hideCursor + clearScreen);

  final Random random = Random();
  final int terminalHeight = stdout.terminalLines;
  final int terminalWidth = stdout.terminalColumns;
  final int fireworkColumn = terminalWidth ~/ 2;

  // Firework will stop after 10 attempts
  for (int attempt = 0; attempt < 10; attempt++) {
    await launchFirework(random, terminalHeight, fireworkColumn, attempt + 1);
  }

  // Show the cursor again after finishing
  stdout.write(showCursor);
}

Future<void> launchFirework(
    Random random, int height, int column, int attempt) async {
  final int colorIndex = random.nextInt(colors.length);
  final String color = colors[colorIndex];
  final String backgroundColor = basicBackgroundColors[colorIndex];

  printFireworkNumber(attempt);

  // Firework rise
  for (int i = height - 1; i > height ~/ 4; i--) {
    // Move cursor to position
    stdout.write('\x1B[${i};${column}H');
    stdout.write(color + boldText + '|' + resetColor);

    await Future.delayed(Duration(milliseconds: 100));

    // Clear the previous position
    stdout.write('\x1B[${i};${column}H ');
  }

  // Explosion with full terminal background color change
  await explode(random, height ~/ 4, column, color, backgroundColor);
}

void printFireworkNumber(int attempt) {
  stdout.write(clearScreen);
  stdout.write('\x1B[1;1H'); // Move to the top left
  stdout.write(boldText + 'Firework attempt: $attempt / 10' + resetColor);
}

Future<void> explode(Random random, int row, int column, String color,
    String backgroundColor) async {
  const explosionChars = '*'; // Simpler character for the explosion

  // Simulate full terminal background color change
  fillTerminalWithColor(backgroundColor);

  for (int frame = 1; frame <= 3; frame++) {
    // Draw explosion in a cross-like pattern
    for (int i = -frame; i <= frame; i++) {
      for (int j = -frame; j <= frame; j++) {
        if (i == 0 || j == 0) {
          // Move to position
          stdout.write('\x1B[${row + i};${column + j}H');
          stdout.write(color + boldText + explosionChars + resetColor);
        }
      }
    }

    await Future.delayed(Duration(milliseconds: 200));

    // Clear explosion after frame
    stdout.write('\x1B[49m'); // Reset background to default
    for (int i = -frame; i <= frame; i++) {
      for (int j = -frame; j <= frame; j++) {
        if (i == 0 || j == 0) {
          stdout.write('\x1B[${row + i};${column + j}H ');
        }
      }
    }
  }
}

void fillTerminalWithColor(String backgroundColor) {
  final int terminalHeight = stdout.terminalLines;
  final int terminalWidth = stdout.terminalColumns;

  // Set the background color
  stdout.write(backgroundColor);

  // Fill the entire screen with the background color using spaces
  for (int i = 0; i < terminalHeight; i++) {
    stdout.write('\x1B[${i};1H'); // Move to start of the line
    stdout.write(' ' * terminalWidth); // Fill the line with spaces
  }

  // Reset the background color after filling
  stdout.write(resetColor);
}
