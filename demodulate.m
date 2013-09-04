function [ QI ] = demodulate(dataStream, symbolDuration, carrierPeriod)
% demodulate - Takes a stream of samples, a carrier period, and a
% symbol duration (in samples) and demodulates, returning
% a list of Q+jI values.

    QI = [];
    numSymbols = floor(length(dataStream)/symbolDuration);
    w = 2*pi/carrierPeriod;   % angular frequency of the carrier

    for symbolNum=0:numSymbols-1
        timeValues = (symbolNum*symbolDuration+1):((symbolNum+1)*symbolDuration);
        symbolData = dataStream(timeValues);
        cosineComponent = sum(symbolData.*cos(w.*(timeValues-1)))/length(timeValues);
        sineComponent = sum(symbolData.*sin(w.*(timeValues-1)))/length(timeValues);
        QI = cat(2, QI, (cosineComponent + 1j*sineComponent));
    end
    
    QI = QI * 2;
    
end



