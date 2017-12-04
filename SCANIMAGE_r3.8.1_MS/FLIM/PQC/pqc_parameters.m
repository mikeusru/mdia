function pqc_parameters

pq.binning = 0;
pq.sync_offset = 800;
pq.sync_channel_offset = 0;
pq.sync_div = 4;
pq.sync_trigger_level = -60;
pq.input_trigger_level = -60;
pq.input_zc_level = 0;
pq.input_zc_level = [0,0];
pq.input_offset = [0,60];
pq.input_trigger_level = [-60, -60];
pq.resolution = 250;

b = PQC_setParameters(0, pq, 1);
