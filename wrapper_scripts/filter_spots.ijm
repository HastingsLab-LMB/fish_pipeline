args = getArgument();
args = split(args, ";");
csv = args[0]
mask = args[1]
save_dir = args[2]

setBatchMode(true);

run("Mask Filtering", "browse=" + mask + " inputs=" + csv + " mask=" + mask + " output=" + save_dir + " exclude=0");
