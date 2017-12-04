function background = r_getBackground(filename);

[Aout, header] = genericOpenTif(filename);
%mean(mean(Aout(:,:,1), 1), 2)
background(1) =mean(mean(Aout(:,:,1), 1), 2);
background(2) =mean(mean(Aout(:,:,2), 1), 2);