function start()
    tic
    % align left ears
    createDatabase('l');
    % align right ears
    createDatabase('r');
    
    time = toc;
    disp(['Ended in ', num2str(time), ' seconds!']);
end