(import "float/float.bin" 'floatlib)
(import "ws2812/ws2812.bin" 'ws2812)

(load-native-lib floatlib)
(load-native-lib ws2812)

;(def led-num 44)
(define led-num (+ (ext-float-dbg 20) (ext-float-dbg 21)))
(define is-rgswapped (ext-float-dbg 28))
(def colors '(0x00000000i32 0xFFFFFFFFi32 0x00FF0000i32 0x0000FF00i32 0x000000FFi32 0x007F7F00i32 0x00007F7Fi32 0x004F00FFi32))
(define leds-enabled (ext-float-dbg 18))

(if (= leds-enabled 1) (let (
    (use-ch2 0) ; 0 means CH1
    (use-tim4 1) ; 0 means TIM3
    (is-rgbw 0)) ; Some adressable LEDs have an extra white channel. Set this to 1 to use it
    ;(is-rgswapped 1)) ; 1 reverses order of red and green data
        (ext-ws2812-init led-num use-ch2 use-tim4 is-rgbw is-rgswapped)
))

; Switch Balance App to UART App
(if (= (conf-get 'app-to-use) 9) (conf-set 'app-to-use 3))

; Set firmware version:
(apply ext-set-fw-version (sysinfo 'fw-ver))

; Set to 1 to monitor some debug variables using the extension ext-euc-dbg
(define debug 1)
;(define led-num (+ (ext-float-dbg 20) (ext-float-dbg 21)))
(if (= debug 1)
    (loopwhile t
      (looprange i 0 led-num
        (progn
            (define setpoint (ext-float-dbg 2))
            (define tt-filtered-current (ext-float-dbg 3))
            (define integral (ext-float-dbg 14))
            (define absERPM (ext-float-dbg 8))
            (define led-on (ext-float-dbg 19))
            (define num-led-front (ext-float-dbg 20))
            (define num-led-back (ext-float-dbg 21))
            (define led-fwd-color (ext-float-dbg 22))
            (define led-back-color (ext-float-dbg 23))
            (define led-charge-color (ext-float-dbg 24))
            (define led-background-color (ext-float-dbg 25))
            (define switch-state (ext-float-dbg 26))
            (define forward-movement (ext-float-dbg 27))
            (if (= leds-enabled 1)
            (if (= led-on 1)    
                (if (> switch-state 0)
                    (if (= forward-movement 1)
                        (if (< i num-led-front)
                            (ext-ws2812-set-color i (ix colors led-fwd-color))
                            (ext-ws2812-set-color i (ix colors led-back-color))
                            ; (ext-ws2812-set-color i 0)
                        )
                        (if (< i num-led-front)
                            (ext-ws2812-set-color i (ix colors led-back-color))
                            (ext-ws2812-set-color i (ix colors led-fwd-color))
                            ; (ext-ws2812-set-color i 0)
                        )
                        
                        
                    )
            
                    (if (< i (* num-led-front (get-batt)))
                        (ext-ws2812-set-color i (ix colors led-charge-color))
                        (ext-ws2812-set-color i (ix colors led-background-color))
                        ; (ext-ws2812-set-color i 0)
                    )    
                )
                (ext-ws2812-set-color i 0)
            )    
            )
            
         )

 
        )
            (sleep 0.05)
))
