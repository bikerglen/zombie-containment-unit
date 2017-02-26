#include </Applications/microchip/xc16/v1.25/support/generic/h/xc.h>
#include </Applications/microchip/xc16/v1.25/support/PIC24F/h/p24FJ128GA202.h>

#pragma config FNOSC    = PRI
#pragma config POSCMD   = EC
#pragma config OSCIOFCN = ON
#pragma config JTAGEN   = OFF
#pragma config FWDTEN   = OFF
#pragma config ICS      = PGx1

#define FOSC 10000000
#define FCY   5000000

#define U1BAUDRATE 38400
#define U1BRGVAL (((FCY/U1BAUDRATE)/16) - 1)

#define U2BAUDRATE 38400
#define U2BRGVAL (((FCY/U2BAUDRATE)/16) - 1)

#define U3BAUDRATE 38400
#define U3BRGVAL (((FCY/U3BAUDRATE)/16) - 1)

#define false 0
#define true -1

void BlinkLed1 (void);
void BlinkButton (void);
unsigned char CheckButton (void);
void DetectMediaPlayers (void);
void ChangeState (void);


unsigned char button_state;

unsigned char mp0_found;
unsigned char mp0_lastResponseValid;
unsigned char mp0_lastResponse;
unsigned char mp0_ticksSinceLastResponse;
unsigned char mp0_responsesReceived;
unsigned char mp1_found;
unsigned char mp1_lastResponseValid;
unsigned char mp1_lastResponse;
unsigned char mp1_ticksSinceLastResponse;
unsigned char mp1_responsesReceived;

unsigned char led1_blink_state;
unsigned char led1_blink_timer;
unsigned char led1_blink_count;

unsigned char button_blink_state;
unsigned char button_blink_timer;

unsigned char state;

unsigned char delay_timer;

#define IDLE    0
#define PREROLL 1
#define ROLLING 2

int main() 
{
	// unlock peripheral pin select and leave it unlocked
	__builtin_write_OSCCONL (OSCCON & ~(1<<6));

    ANSA = 0;               // no analog pins on port a
    ANSB = 0;               // no analog pins on port b
    
    TRISBbits.TRISB2 = 0;   // LED 1 output
    TRISBbits.TRISB3 = 0;   // LED 2 output
    TRISAbits.TRISA3 = 0;   // LED 3 output
    TRISBbits.TRISB5 = 0;   // LED 4 output
    
    TRISAbits.TRISA0 = 1;   // arcade button switch input
    TRISAbits.TRISA1 = 0;   // arcade button light output
    
    TRISBbits.TRISB8 = 0;   // TXD0 output
    TRISBbits.TRISB9 = 1;   // RXD0 input
    TRISBbits.TRISB6 = 0;   // TXD1 output
    TRISBbits.TRISB7 = 1;   // RXD1 input
    TRISBbits.TRISB10 = 0;  // TXD2 output
    TRISBbits.TRISB12 = 1;  // RXD2 input
    TRISBbits.TRISB11 = 0;  // TXD2/RXD2 direction control output
    
    LATBbits.LATB2 = 1;     // LED 1 off
    LATBbits.LATB3 = 1;     // LED 2 off
    LATAbits.LATA3 = 1;     // LED 3 off
    LATBbits.LATB5 = 1;     // LED 4 off
    
    LATBbits.LATB11 = 1;    // set TXD2/RXD2 for transmit
    
    LATAbits.LATA1 = 0;     // arcade button light off
    
    // assign uart functions to pins
    RPINR18bits.U1RXR =  9; // assign U1RX to pin RP9
    RPINR19bits.U2RXR =  7; // assign U2RX to pin RP7
    RPINR17bits.U3RXR = 12; // assign U3RX to pin RP12
    RPOR4bits.RP8R =  3;    // assign U1TX to pin RP8
    RPOR3bits.RP6R =  5;    // assign U2TX to pin RP6
    RPOR5bits.RP10R = 19;   // assign U3TX to pin RP10
    
    // initialize uarts
    U1MODE = 0b1000000000000000;    // UARTEN
	U1STA  = 0b0001010000000000;    // URXEN + UTXEN
	U1BRG = U1BRGVAL;
    U2MODE = 0b1000000000000000;    // UARTEN
	U2STA  = 0b0001010000000000;    // URXEN + UTXEN
	U2BRG = U2BRGVAL;
    U3MODE = 0b1000000000000000;    // UARTEN
	U3STA  = 0b0001010000000000;    // URXEN + UTXEN
	U3BRG = U3BRGVAL;
    
    // initialize timer 1 for 50Hz / 20ms period
    // Fcy / prescale / period = 10MHz / 64 / 3125 = 50Hz / 20ms
    _T1IF = 0;
    _T1IE = 0;
    TMR1 = 0x0000;
    PR1 = 3125;
    T1CONbits.TCKPS = 2;
    T1CONbits.TON = 1;

    button_state = 0;
    led1_blink_state = 1;
    button_blink_state = 0;
    ChangeState ();
    
    DetectMediaPlayers ();
    
    state = IDLE;
    led1_blink_state = 2;
    button_blink_state = 1;
    ChangeState ();
    
    while (1) {
        
        // clear any over runs
        if (U1STAbits.OERR) {
            U1STAbits.OERR = 0;
        }
        if (U2STAbits.OERR) {
            U2STAbits.OERR = 0;
        }
        if (U3STAbits.OERR) {
            U3STAbits.OERR = 0;
        }
        
        // do periodic tasks when timer expires
        if (_T1IF == 1) {
            _T1IF = 0;
            BlinkLed1 ();   
            BlinkButton ();
            switch (state) {
                case IDLE:
                    U3TXREG = 'I';
                    break;
                case PREROLL:
                    U3TXREG = 'P';
                    break;
                case ROLLING:
                    U3TXREG = 'R';
                    break;
            }
            if (delay_timer != 0) {
                delay_timer--;
            }
        }

        switch (state) {
            case IDLE:
                // wait for button
                if (CheckButton ()) {
                    state = PREROLL;
                    led1_blink_state = 3;
                    button_blink_state = 2;
                    U1TXREG = 0x01;
                    U2TXREG = 0x01;
                    delay_timer = 150;
                    ChangeState ();
                }
                break;
            case PREROLL:
                // wait for found media players to switch from 0x00 to 0x01
                // wait at least three seconds so button blinks some before turning off for the rolling state
                if ((!mp0_found || (mp0_lastResponseValid && (mp0_lastResponse == 0x01))) &&
                        (!mp1_found || (mp1_lastResponseValid && (mp1_lastResponse == 0x01))) && 
                        (delay_timer == 0)) {
                    state = ROLLING;
                    led1_blink_state = 4;
                    button_blink_state = 0;
                    ChangeState ();
                }
                break;
            case ROLLING:
                // wait for found media players to switch from 0x01 to 0x00
                if ((!mp0_found || (mp0_lastResponseValid && (mp0_lastResponse == 0x00))) &&
                        (!mp1_found || (mp1_lastResponseValid && (mp1_lastResponse == 0x00)))) {
                    state = IDLE;
                    led1_blink_state = 2;
                    button_blink_state = 1;
                    ChangeState ();
                }
                break;
        }
        
        if (U1STAbits.URXDA) {
            mp0_lastResponse = U1RXREG;
            mp0_lastResponseValid = true;
            LATAbits.LATA3 = LATAbits.LATA3 ? 0 : 1;
        }
        if (U2STAbits.URXDA) {
            mp1_lastResponse = U2RXREG;
            mp1_lastResponseValid = true;
            LATBbits.LATB5 = LATBbits.LATB5 ? 0 : 1;
        }
    }
    
    return 0;
}
    

void BlinkLed1 (void)
{
    // tenth second on / tenth second off for each count in led1 blink state
    // then a 0.4 second off between blinks
    
    if (led1_blink_count < led1_blink_state) {
        if (led1_blink_timer < 5) {
            // on
            LATBbits.LATB2 = 0;
            led1_blink_timer++;
        } else if (led1_blink_timer < 10) {
            // off
            LATBbits.LATB2 = 1;
            led1_blink_timer++;
        } else {
            led1_blink_timer = 0;
            led1_blink_count++;
        }
    } else {
        if (led1_blink_timer < 20) {
            led1_blink_timer++;
        } else {
            led1_blink_timer = 0;
            led1_blink_count = 0;
        }
    }
}


void BlinkButton (void)
{
    if (button_blink_state == 0) {
        // steady off
        LATAbits.LATA1 = 0;
    } else if (button_blink_state == 1) {
        // steady on
        LATAbits.LATA1 = 1;
    } else {
        // quick blink
        if (button_blink_timer < 5) {
            // on
            LATAbits.LATA1 = 1;
            button_blink_timer++;
        } else if (button_blink_timer < 10) {
            // off
            LATAbits.LATA1 = 0;
            button_blink_timer++;
        } else {
            button_blink_timer = 0;
        }
    }
}

    
unsigned char CheckButton (void)
{
    switch (button_state) {
        case 0: // if button down, advance to state 1
            if (!PORTAbits.RA0) {
                button_state = 1;
            }
            break;
        case 1: // if button still down, count that as a press and advance to state 2
            if (!PORTAbits.RA0) {
                button_state = 2;
                return 1;
            } else {
                button_state = 0;
            }
            break;
        case 2: // if button up, advance to state 3
            if (PORTAbits.RA0) {
                button_state = 3;
            }
            break;
        case 3: // if button still up, reset state machine and look for next press
            if (PORTAbits.RA0) {
                button_state = 0;
            } else {
                button_state = 2;
            }
            break;
        default:
            button_state = 0;
            break;
    }
    
    return 0;
}
    
    
void DetectMediaPlayers (void)
{
    mp0_found = false;
    mp0_lastResponse = 0;
    mp0_ticksSinceLastResponse = 0;
    mp0_responsesReceived = 0;

    mp1_found = false;
    mp1_lastResponse = 0;
    mp1_ticksSinceLastResponse = 0;
    mp1_responsesReceived = 0;

    while (1) {

        // clear any over runs
        if (U1STAbits.OERR) {
            U1STAbits.OERR = 0;
        }
        if (U2STAbits.OERR) {
            U2STAbits.OERR = 0;
        }
        if (U3STAbits.OERR) {
            U3STAbits.OERR = 0;
        }
        
        // do periodic tasks when timer expires
        if (_T1IF == 1) {
            _T1IF = 0;

            // blink LED 1 in the state 1 pattern
            BlinkLed1 ();
            
            // blink button
            BlinkButton ();
            
            // if button is pressed while in the detect media player state and 
            // at least one media player is found, go ahead and exit and run
            // program using only a single media player.
            if (CheckButton ()) {
                if (mp0_found || mp1_found) {
                    break;
                }
            }
            
            // increment ticks since last response received for each media player
            if (mp0_ticksSinceLastResponse != 255) {
                mp0_ticksSinceLastResponse++;
            }
            if (mp1_ticksSinceLastResponse != 255) {
                mp1_ticksSinceLastResponse++;
            }
            
            // signal downstream devices that we're in the media player detect state
            U3TXREG = 'D';
        }
        
        // check media player 0 serial port for a 0x00 / idle video character
        if (U1STAbits.URXDA) {
            mp0_lastResponse = U1RXREG;
            LATAbits.LATA3 = LATAbits.LATA3 ? 0 : 1;
            if (mp0_lastResponse == 0) { // && (mp0_ticksSinceLastResponse > 20) && (mp0_ticksSinceLastResponse < 30)) {
                if (mp0_responsesReceived != 255) {
                    mp0_responsesReceived++;
                }
            } else {
                mp0_responsesReceived = 0;
            }
            mp0_ticksSinceLastResponse = 0;
        }

        // check media player 1 serial port for a 0x00 / idle video character
        if (U2STAbits.URXDA) {
            mp1_lastResponse = U2RXREG;
            LATBbits.LATB5 = LATBbits.LATB5 ? 0 : 1;
            if (mp1_lastResponse == 0) { // && (mp1_ticksSinceLastResponse > 20) && (mp1_ticksSinceLastResponse < 30)) {
                if (mp1_responsesReceived != 255) {
                    mp1_responsesReceived++;
                }
            } else {
                mp1_responsesReceived = 0;
            }
            mp1_ticksSinceLastResponse = 0;
        }

        // found when 5 idle responses are received in a row within 400ms and 600ms
        mp0_found = mp0_responsesReceived > 5;
        mp1_found = mp1_responsesReceived > 5;
            
        // once both media players are found, exit the detect media players state
        if (mp0_found && mp1_found) {
            break;
        }
    }
}


void ChangeState (void)
{
    led1_blink_timer = 0;
    led1_blink_count = 0;
    button_blink_timer = 0;
    mp0_lastResponseValid = false;
    mp1_lastResponseValid = false;
}



