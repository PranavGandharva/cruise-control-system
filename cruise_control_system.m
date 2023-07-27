a = arduino('COM4','Uno','Libraries',{'Ultrasonic' 'ExampleLCD/LCDAddon'},'ForceBuildOn',true)
x=0;
f=0;
speed = 0;
cur_speed = 0;
max_speed = 40;
set_speed = 0;
cursetspeed = 0;
can_state = 0;
increase = 'D13';
decrease = 'D12';
cruise = 'D11';
adp = 'D10';
cancel = 'A2';
cru = 0;
adc = 0;
tempStepCru = 0;
tempStepThreshCru = 10;
tempStep = 0;
tempStepThresh = 4;
set_adp_cruise = 0;
stored_speed = 0;
ultrasonicObj = ultrasonic(a,'D8','D9');
lcd = addon(a,'ExampleLCD/LCDAddon','RegisterSelectPin','D7','EnablePin','D6','DataPins',{'D5','D4','D3','D2'});
initializeLCD(lcd,'Rows',2,'Column',16);
printLCD(lcd,'Welcome')
pause(2)
initializeLCD(lcd)
mode=3;
while 1
    Z='SPEED:';
    K='MODE:';
    L=["CC-SET","ADAPT","NORMAL","CANCEL"];
    Y=num2str(L(mode));
    t=num2str(cur_speed);
    printLCD(lcd,[Z t]);
    printLCD(lcd,[K Y]);
    inc_state = readDigitalPin(a,increase);
    dec_state = readDigitalPin(a,decrease);
    cru_state = readDigitalPin(a,cruise);
    adp_state = readDigitalPin(a,adp);
    can_state = readVoltage(a,cancel);
    d = readDistance(ultrasonicObj);
    distance = (d*343)/2;
    % INCREASE BUTTON FUNCTIONALITY (ACCELERATOR)
    if inc_state == 0 && cur_speed <= max_speed && adp_state == 1 && set_speed==0 && set_adp_cruise == 0
        cur_speed = cur_speed + 1;
        mode=3
        printLCD(lcd,['Speed' num2str(cur_speed)]);
        printLCD(lcd,[K Y]);
    end
    %DECREASING BUTTON FUNCTIONALITY (DECELERATOR)
    if dec_state == 0 && cur_speed > 0 && adp_state == 1 && set_speed==0 && set_adp_cruise == 0
        cur_speed = cur_speed - 1;
        mode=3;
        printLCD(lcd,['Speed' num2str(cur_speed)]);
        printLCD(lcd,[K Y]);
    end
    % CRUSIE CONTROL MODE WHICH SETS THE SPEED OF THE CAR WHILE RUNNING
    if cru_state == 0 && adp_state == 1 && f==0 && set_adp_cruise == 0
        f=1
        set_speed = 1;
        mode=1;
        printLCD(lcd,['Speed' num2str(cur_speed)]);
        printLCD(lcd,[K Y]);
    end
    if set_speed == 1 && inc_state == 0 && set_adp_cruise == 0
        cur_speed = cur_speed + 1;
        mode=1;
        printLCD(lcd,['Speed' num2str(cur_speed)]);
        printLCD(lcd,[K Y])
    end
    if set_speed == 1 && dec_state == 0 &&  set_adp_cruise == 0
        cur_speed = cur_speed - 1;
        mode=1;
        printLCD(lcd,['Speed' num2str(cur_speed)]);
        printLCD(lcd,[K Y])
    end
    % ADAPTIVE CRUSIE CONTROL MODE FOR AUTOMATIC CONTROL OF SPEED (INCREASE OR
    % DECREASE ACCORDING TO DISTANCE BETWEEN OBSTACLE AND CAR)
    if  adp_state == 0  && f==1
        set_adp_cruise = 1;
        mode=2
        printLCD(lcd,['Speed' num2str(cur_speed)]);
        printLCD(lcd,[K Y])
    end
    if set_adp_cruise == 1
        tempStep = tempStep + 1
        if distance < 20 && cur_speed > 0
            if stored_speed < cur_speed
                stored_speed = cur_speed;
            end
            if mod(tempStep , tempStepThresh ) == 0
                cur_speed = cur_speed - 1;
                mode=2
                tempStep = 0;
            end
        else
            if stored_speed > cur_speed
                if mod(tempStep , tempStepThresh ) == 0
                    cur_speed = cur_speed + 1;
                    mode=2
                    tempStep = 0;
                end
            end
        end
    end
    % CANCEL BUTTON FUNCTIONALITY SET OF ALL FUCTIONALITY BACK TO NORMAL MODE
    if can_state <=2
        f=0
        adp_state = 1
        cru_state = 1
        set_adp_cruise = 0
        set_speed = 0
        mode=3
        cur_speed=cur_speed-1;
        printLCD(lcd,['Speed' num2str(cur_speed)]);
        printLCD(lcd,[K Y])
    end
    % (automatic speed decreasing)
    if  inc_state == 1 && dec_state == 1  && cru_state == 1 && cur_speed > 0 && set_speed==0 && set_adp_cruise == 0
        pause(0.5)
        cur_speed=cur_speed-1;
        printLCD(lcd,['Speed' num2str(cur_speed)]);
        printLCD(lcd,[K Y]);
    end
end

