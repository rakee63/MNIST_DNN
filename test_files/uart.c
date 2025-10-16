#include <windows.h>
#include <stdio.h>
#include <string.h>

#define MAX_LINE 256   // max characters per line

// Function to convert binary string to unsigned short
unsigned short bin_to_uint16(const char *bin_str) {
    unsigned short value = 0;
    while (*bin_str) {
        value = (value << 1) | (*bin_str - '0');
        bin_str++;
    }
    return value;
}

int main() {
    HANDLE hSerial;
    DCB dcbSerialParams = {0};
    COMMTIMEOUTS timeouts = {0};

    // Open COM port
    hSerial = CreateFile(
        "\\\\.\\COM12", GENERIC_WRITE, 0, NULL,
        OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);

    if (hSerial == INVALID_HANDLE_VALUE) {
        printf("Error opening COM port\n");
        return 1;
    }

    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
    if (!GetCommState(hSerial, &dcbSerialParams)) {
        printf("Error getting state\n");
        return 1;
    }

    // Configure 115200 8N1
    dcbSerialParams.BaudRate = CBR_115200;
    dcbSerialParams.ByteSize = 8;
    dcbSerialParams.StopBits = ONESTOPBIT;
    dcbSerialParams.Parity   = NOPARITY;

    if (!SetCommState(hSerial, &dcbSerialParams)) {
        printf("Error setting state\n");
        return 1;
    }

    // Set timeouts
    timeouts.ReadIntervalTimeout = 50;
    timeouts.ReadTotalTimeoutConstant = 50;
    timeouts.ReadTotalTimeoutMultiplier = 10;
    timeouts.WriteTotalTimeoutConstant = 50;
    timeouts.WriteTotalTimeoutMultiplier = 10;
    SetCommTimeouts(hSerial, &timeouts);

    // Open input text file
    FILE *fp = fopen("D:/MTech_Project/Projects/neuralNetwork-master/test_data/test_data_9980.txt", "r");
    if (!fp) {
        printf("Error opening data file\n");
        CloseHandle(hSerial);
        return 1;
    }

    char line[MAX_LINE];
    DWORD bytes_written;
    int line_num = 0;

    while (fgets(line, sizeof(line), fp)) {
        line_num++;

        // Remove newline
        line[strcspn(line, "\r\n")] = 0;

        // Pad to 16 bits if needed
        char padded[17];
        int len = strlen(line);
        if (len < 16) {
            sprintf(padded, "%016s", line); // pad with leading zeros
        } else {
            strncpy(padded, line, 16);
            padded[16] = '\0';
        }

        // Convert to 16-bit number
        unsigned short data_word = bin_to_uint16(padded);

        // Split into two bytes: LSB first, then MSB
        unsigned char buffer[2];
        buffer[0] = data_word & 0xFF;        // low byte
        buffer[1] = (data_word >> 8) & 0xFF; // high byte

        if(line_num==785){
            printf("\nData is sent :)\n");
            printf("\nExpected digit is %u\n\n", buffer[0]);
            break;
        }

        // Send bytes
        WriteFile(hSerial, buffer, 2, &bytes_written, NULL);

        printf("Line %d: %s -> 0x%04X (sent LSB=0x%02X, MSB=0x%02X)\n",
               line_num, padded, data_word, buffer[0], buffer[1]);
    }

    fclose(fp);
    CloseHandle(hSerial);
    return 0;
}
