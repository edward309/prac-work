function [ out ] = modulate3( data, modulation, carrierPeriod)
% modulate - Takes data, a modulation scheme, and a specification of
% samples per carrier period.
% Requires that the data be of a valid length depending on choice of
% modulation.
    out = [];
    f = 100; % hz
    w = 2*pi*f;
    samplesPerSecond = f*carrierPeriod;
    Rb = 25; % bit rate (per second)
    Tb = 1/Rb;
    Ts = Tb; % Ts is symbol duration. Default value. In seconds.

    if strcmpi(modulation, 'BPSK')
        QI = pskmod(data, 2); 
        Ts = Tb*1;
    end
    if strcmpi(modulation, 'QPSK')
        symbolValues = [];
        
        for symbolNum = 0:length(data)/2-1
            symbolBits = data(symbolNum*2+1:(symbolNum)*2+2);
            symbolValues = cat(2, symbolValues, ...
                symbolBits(1) + 2*symbolBits(2));
        end
        QI = pskmod(symbolValues, 4);
        Ts = Tb*2;
    end
    if strcmpi(modulation, '16-QAM')
        %binarySymbols = reshape(data, 16, [])';
        %symbols = bi2de(binarySymbols)';
        % Create a rectangular 8-QAM modulator System object with bits as inputs 
        % and Gray-coded signal constellation
        hModulator = comm.RectangularQAMModulator(16,'BitInput',true);
        QI = step(hModulator, data');
        Ts = Tb*4;
    end
    if strcmpi(modulation, 'DPSK')
        hModulator = comm.DBPSKModulator();
        QI = step(hModulator, data');
        Ts = Tb*1;
    end
    if (strcmpi(modulation, '90deg-DPQSK'))
        h = comm.DQPSKModulator(pi/4);
        QI = step(h, data');
        Ts = Tb*1;
    end

    % Times, in seconds, to evaluate sine wave for across symbol duration.
    t = 0:(1/(samplesPerSecond)):Ts;
    t = t(1:end-1);

    for symbolNum=1:length(QI)
        out = cat(2, out, abs(QI(symbolNum))*exp(1i*w*t + 1i*angle(QI(symbolNum))));
    end

end

