%% Setup
clear; clc

a = arduino('COM4', 'Uno', 'Libraries', {'Servo', 'Ultrasonic'});
motor = servo(a, 'D9');
sensor = ultrasonic(a, 'D5', 'D6');

%% Measure
MEASURES_PER_POS = 5;

theta = linspace(0, pi, 90);
R = zeros(1, length(theta));

plt = polarplot(theta, R, 'color', 'g');
linkdata on

configure_plot

first_sweep = true;
theta_indices = 1:length(theta);

while true
    for index = theta_indices
        writePosition(motor, theta(index) / pi);
        
        if first_sweep
            R(index) = makeMeasurement(sensor, MEASURES_PER_POS);
        else
            R(index) = ...
                (R(index) + makeMeasurement(sensor, MEASURES_PER_POS)) / 2;
        end
        
        refreshdata
    end
    
    if first_sweep
        first_sweep = false;
    end
    
    theta_indices = fliplr(theta_indices);
end

function configure_plot
    thetalim([0 180]);
    
    pax = gca;
    pax.ThetaColor = 'green';
    pax.RColor = 'green';
    pax.GridColor = 'green';
    
    set(gca, 'color', 'black')
    set(gcf, 'color', 'black')
end

function distance = makeMeasurement(sensor, iters)
    sum = 0;
    for cnt = 1:iters
        sum = sum + readDistance(sensor);
        pause(0.05);
    end  
    distance = sum / iters;
end
