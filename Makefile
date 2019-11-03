# Makefile for AskSin OTA bootloader
#
# Instructions
#
# To make bootloader .hex file:
# make HM_LC_Sw1PBU_FM
# make HB_UW_Sen_THPL
# etc...
#

# program name should not be changed...
PROGRAM          = Bootloader-AskSin-OTA
F_CPU            = 8000000
SUFFIX           =

CC               = avr-gcc
OPTIMIZE         = -Os

OBJCOPY          = avr-objcopy
FORMAT           = ihex

# Override is only needed by avr-lib build system.
override CFLAGS  = -g -Wall $(OPTIMIZE) -mmcu=$(MCU) -DF_CPU=$(F_CPU)
override LDFLAGS = -Wl,--section-start=.text=${BOOTLOADER_START},--section-start=.bootloaderUpdate=${BOOTLOADER_UPDATE_START},--section-start=.addressDataType=${ADDRESS_DATA_TYPE_START},--section-start=.addressDataSerial=${ADDRESS_DATA_SERIAL_START},--section-start=.addressDataId=${ADDRESS_DATA_ID_START}
override LDFLAGS_OTA = -Wl,--section-start=.text=${BOOTLOADER_START_OTA},--section-start=.bootloaderUpdate=${BOOTLOADER_UPDATE_START},--section-start=.addressDataType=${ADDRESS_DATA_TYPE_START},--section-start=.addressDataSerial=${ADDRESS_DATA_SERIAL_START},--section-start=.addressDataId=${ADDRESS_DATA_ID_START},--section-start=.addressDataOTABOOTLOADER=${ADDRESS_SECTION_OTABOOTLOADER}

all:

# Settings for HM_LC_Sw1PBU_FM (Atmega644, 4k Bootloader size)
#
# CODE_END:                lenth of program space (adress of crc-check data is at CODE_END - 1)
# BOOTLOADER_START:        Start address of the bootoader   (4k bootloader space)
# ADDRESS_DATA_START:      Start address of adressdata      (last 16 bytes in flash)
# BOOTLOADER_PAGES         Number of pages in the bootloader section (remember 328p and 644a have different page size)
# BOOTLOADER_UPDATE_START  Start address of protected .bootloaderUpdate section for OTA self update function
#

# Settings for ATmega328P, 4K Bootloader size
ATmega328P:         TARGET                    = ATmega328P
ATmega328P:         MCU                       = atmega328p
ATmega328P:         CODE_END                  = 0x6FFF
ATmega328P:         BOOTLOADER_PAGES          = 30
ATmega328P:         BOOTLOADER_UPDATE_START   = 0x7F00

ATmega328P:         BOOTLOADER_START          = 0x7000
ATmega328P:         ADDRESS_DATA_TYPE_START   = 0x7FF0
ATmega328P:         ADDRESS_DATA_SERIAL_START = 0x7FF2
ATmega328P:         ADDRESS_DATA_ID_START     = 0x7FFC
ATmega328P:         hex

# Settings for ATmega644P, 8K Bootloader size
ATmega644P:         TARGET                    = ATmega644P
ATmega644P:         MCU                       = atmega644p
ATmega644P:         CODE_END                  = 0xDFFF
ATmega644P:         BOOTLOADER_PAGES          = 31
ATmega644P:         BOOTLOADER_UPDATE_START   = 0xFF00

ATmega644P:         BOOTLOADER_START          = 0xE000
ATmega644P:         ADDRESS_DATA_TYPE_START   = 0xFFF0
ATmega644P:         ADDRESS_DATA_SERIAL_START = 0xFFF2
ATmega644P:         ADDRESS_DATA_ID_START     = 0xFFFC
ATmega644P:         hex

# Settings for ATmega1284P, 8K Bootloader size
ATmega1284P:        TARGET                    = ATmega1284P
ATmega1284P:        MCU                       = atmega1284p
ATmega1284P:        CODE_END                  = 0x1DFFF
ATmega1284P:        BOOTLOADER_PAGES          = 31
ATmega1284P:        BOOTLOADER_UPDATE_START   = 0x1FF00

ATmega1284P:        BOOTLOADER_START          = 0x1E000
ATmega1284P:        ADDRESS_DATA_TYPE_START   = 0x1FFF0
ATmega1284P:        ADDRESS_DATA_SERIAL_START = 0x1FFF2
ATmega1284P:        ADDRESS_DATA_ID_START     = 0x1FFFC
ATmega1284P:        hex


Atmega328p_OTA:     TARGET                    = Atmega328p_OTA
Atmega328p_OTA:     MCU                       = atmega328p
Atmega328p_OTA:	    CODE_END                  = 0x6FFF
Atmega328p_OTA:     BOOTLOADER_PAGES          = 30
Atmega328p_OTA:     BOOTLOADER_UPDATE_START   = 0x7F00

Atmega328p_OTA:     BOOTLOADER_START          = 0x7000
Atmega328p_OTA:     BOOTLOADER_START_OTA      = 0x0000
Atmega328p_OTA:     ADDRESS_DATA_TYPE_START   = 0x7FF0
Atmega328p_OTA:     ADDRESS_DATA_SERIAL_START = 0x7FF2
Atmega328p_OTA:     ADDRESS_DATA_ID_START     = 0x7FFC
Atmega328p_OTA:     ADDRESS_SECTION_OTABOOTLOADER     = 0x6FFC
Atmega328p_OTA:     hex_ota_generic

hex_ota_generic: uart_code
	$(CC) -Wall -c -std=c99 -mmcu=$(MCU) $(LDFLAGS_OTA) -DF_CPU=$(F_CPU) -D$(TARGET) $(OPTIMIZE) cc.c -o cc.o
	$(CC) -Wall    -std=c99 -mmcu=$(MCU) $(LDFLAGS_OTA) -DF_CPU=$(F_CPU) -D$(TARGET) -DCODE_END=${CODE_END} -DBOOTLOADER_START=${BOOTLOADER_START_OTA} -DBOOTLOADER_PAGES=${BOOTLOADER_PAGES} $(OPTIMIZE) bootloader.c cc.o uart/uart.o -o $(PROGRAM)-$(TARGET)$(SUFFIX).elf
	$(OBJCOPY) -j .text -j .data  -j .addressDataOTABOOTLOADER -O $(FORMAT) $(PROGRAM)-$(TARGET)$(SUFFIX).elf $(PROGRAM)-$(TARGET)$(SUFFIX).hex

	@avr-nm -fsysv -n -S -l -a $(PROGRAM)-$(TARGET)$(SUFFIX).elf
	echo
	@avr-size -C --mcu=$(MCU) $(PROGRAM)-$(TARGET)$(SUFFIX).elf

hex_ota_model: uart_code
	$(CC) -Wall -c -std=c99 -mmcu=$(MCU) $(LDFLAGS_OTA) -DF_CPU=$(F_CPU) -D$(TARGET) $(OPTIMIZE) cc.c -o cc.o
	$(CC) -Wall    -std=c99 -mmcu=$(MCU) $(LDFLAGS_OTA) -DF_CPU=$(F_CPU) -D$(TARGET) -DCODE_END=${CODE_END} -DBOOTLOADER_START=${BOOTLOADER_START_OTA} -DBOOTLOADER_PAGES=${BOOTLOADER_PAGES} $(OPTIMIZE) bootloader.c cc.o uart/uart.o -o $(PROGRAM)-$(TARGET)$(SUFFIX).elf
	$(OBJCOPY) -j .text -j .data -j .bootloaderUpdate -j .addressDataType -j .addressDataSerial -j .addressDataId  -j .addressDataOTABOOTLOADER -O $(FORMAT) $(PROGRAM)-$(TARGET)$(SUFFIX).elf $(PROGRAM)-$(TARGET)$(SUFFIX).hex

	@avr-nm -fsysv -n -S -l -a $(PROGRAM)-$(TARGET)$(SUFFIX).elf
	echo
	@avr-size -C --mcu=$(MCU) $(PROGRAM)-$(TARGET)$(SUFFIX).elf
	
hex: uart_code
	$(CC) -Wall -c -std=c99 -mmcu=$(MCU) $(LDFLAGS) -DF_CPU=$(F_CPU) -D$(TARGET) $(OPTIMIZE) cc.c -o cc.o
	$(CC) -Wall    -std=c99 -mmcu=$(MCU) $(LDFLAGS) -DF_CPU=$(F_CPU) -D$(TARGET) -DCODE_END=${CODE_END} -DBOOTLOADER_START=${BOOTLOADER_START} -DBOOTLOADER_PAGES=${BOOTLOADER_PAGES} $(OPTIMIZE) bootloader.c cc.o uart/uart.o -o $(PROGRAM)-$(TARGET)$(SUFFIX).elf
	$(OBJCOPY) -j .text -j .data -j .bootloaderUpdate -j .addressDataType -j .addressDataSerial -j .addressDataId -O $(FORMAT) $(PROGRAM)-$(TARGET)$(SUFFIX).elf $(PROGRAM)-$(TARGET)$(SUFFIX).hex

	@avr-nm -fsysv -n -S -l -a $(PROGRAM)-$(TARGET)$(SUFFIX).elf
	echo
	@avr-size -C --mcu=$(MCU) $(PROGRAM)-$(TARGET)$(SUFFIX).elf

uart_code:
	$(MAKE) -C ./uart/ MCU=$(MCU)
	
clean:
	rm -rf *.o *.elf *.lst *.map *.sym *.lss *.eep *.srec *.bin *.hex \
	uart/*.o uart/*.elf uart/*.lst uart/*.map uart/*.sym uart/*.lss uart/*.eep uart/*.srec uart/*.bin uart/*.hex
