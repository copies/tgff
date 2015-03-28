#!/usr/bin/perl

# Copyright 2008 Pavel Ghosh <pghosh2@asu.edu>
# Minor edits by Robert Dick <dickrp@northwestern.edu>

if (scalar (@ARGV) < 1){
	print "\n*************************************\n";
	print "Usage: ./convert.pl <input_file> \n";
	print "\n*************************************\n";
	exit 1;	
}

$inp_file = $ARGV[0];
$out_file = "$inp_file.dot";

open (wr_ptr, ">$out_file") || die "Could not open file $out_file. Exitting ...\n\n";
open (rd_ptr, "<$inp_file") || die "Could not open file $inp_file. Exitting ...\n\n";

$comm_index = 0;
$flag = 0;
$hd_flag = 0;
$sd_flag = 0;
$end = 0;

while (<rd_ptr>){
	if (/^\@HYPERPERIOD (.*)/){
		$hyper_period = $1;
		$hyper_period=~s/\s//g;
	}

	if (/^\@COMMUN_QUANT (.*)/){
		$flag = 1;
	}
	if (/^$comm_index (.*)/ && $flag==1){
		$commun{"$comm_index"} = $1;
		$commun{"$comm_index"}=~s/\s//g;
		$comm_index++;
	}

	if (/^\@TASK_GRAPH (.*)/){
		if ($end==1){
			print wr_ptr "\tlabel=\"";
			if ($hd_flag==1){
				print wr_ptr "$h_dline{$graph_number}";
				$hd_flag = 0;
			}
			if ($sd_flag==1){
				print wr_ptr "$s_dline{$graph_number}";
				$sd_flag = 0;
			}
			print wr_ptr "Period = $period{$graph_number} sec\";\n";
               		print wr_ptr "\}\n\n";
			$end = 0;
		}
		$graph_number = $1;
		$graph_number=~s/\D//g;
		print wr_ptr "digraph G$graph_number\{\n";
		print wr_ptr "\tsize = \"7,9\";\n";
		print wr_ptr "\tcenter = \"true\";\n";
	}

	if (/^[\s]*PERIOD (.*)/){
		$period{"$graph_number"} = $1;
		$period{"$graph_number"}=~s/\s//g;
	}

	if (/^[\s]*TASK(\s[^\s]*\b)/){
		$task_name = $1;
		$task_name=~s/[^a-zA-Z0-9_]//g;
		print wr_ptr "\t$task_name;\n";
	}

	if (/^[\s]*ARC(.*)FROM(.*)TO(.*)TYPE(.*)/){
		$node1 = $2;
		$node2 = $3;
		$label = $4;

		$node1=~s/[^a-zA-Z0-9_]//g;
		$node2=~s/[^a-zA-Z0-9_]//g;
		$label=~s/\s//g;

		print wr_ptr "\t$node1 -> $node2 [label=\"$commun{$label}\"];\n";
	}

	if (/^[\s]*HARD_DEADLINE(.*)ON(.*)AT(.*)/){
		$val1 = $2;
		$val2 = $3;
		$val1=~s/[^a-zA-Z0-9_]//g;
		$val2=~s/\s//g;
		$h_dline{"$graph_number"} = "$h_dline{$graph_number} Hard Deadline : on $val1 at $val2 sec\\n";
		$hd_flag = 1;
		$end = 1;
	}

	if (/^[\s]*SOFT_DEADLINE(.*)ON(.*)AT(.*)/){
		$val1 = $2;
		$val2 = $3;
		$val1=~s/[^a-zA-Z0-9_]//g;
		$val2=~s/\s//g;
		$s_dline{"$graph_number"} = "$s_dline{$graph_number} Soft Deadline : on $val1 at $val2 sec\\n";
		$sd_flag = 1;
		$end = 1;
	}
}

if ($end==1){
	print wr_ptr "\tlabel=\"";
	if ($hd_flag==1){
		print wr_ptr "$h_dline{$graph_number}";
		$hd_flag = 0;
	}
	if ($sd_flag==1){
		print wr_ptr "$s_dline{$graph_number}";
		$sd_flag = 0;
	}
	print wr_ptr "Period = $period{$graph_number} sec\";\n";
        print wr_ptr "\}\n\n";
	$end = 0;
}

close(rd_ptr);
close(wr_ptr);

