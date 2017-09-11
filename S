package ToolKit;
use strict;
use warnings;
use File::Basename;
use FindBin qw($Bin);
#================================================================

#========================= Parse Config =========================
#Description:
#       This Function is use to parse program pathway.
#       Input1: Config file.
#       Input2: program name list.
#       Output: program pathway lsit.
#================================================================
sub ParseConfig{
        my ($config,@program,%path,@out);
        $config = shift @_;
        @program = @_;
        open CONFIG,"$config" or die "Can't open file $config  !!!!\n";
        while(<CONFIG>){
                chomp;
                next if(/^\s*$/ || /^\s*\#/);
                $_ =~ s/^\s*//;
                $_ =~ s/#(.)*//;
                $_ =~ s/\s*$//;
                if (/^(\w+)\s*=\s*(.*)$/xms){
                        next if ($2 =~ /^\s*$/);
                        $path{$1} = $2;
                }
        }
        close(CONFIG);
        foreach my $name ( @program ){
                if(exists($path{$name})){
                        die "$path{$name} file isn't exit \n" unless -e $path{$name};
                        push @out,$path{$name} if -e $path{$name};
                }else{
                        die "Can't find $name program\n";
                }
        }
        return @out;
}
#========================= Generate Shell =======================
#Description:
#       This Function is use to generate script.
#	Input1: shell file pathway.
#	Input2: main content.
#       Output: shell script file.
#================================================================
sub generateShell{
	my ($output_shell, $content, $finish_string) = @_;
	#unlink glob "$output_shell.*";
	$finish_string ||= "Still_waters_run_deep";
	open OUT,">$output_shell" or die "Cannot open file $output_shell:$!";
	print OUT "#!/bin/bash\n";
	print OUT "echo ==========start at : `date` ==========\n";
	print OUT "$content";
	print OUT "echo ==========end at : `date` ========== && \\\n";
	print OUT "echo $finish_string 1>&2 && \\\n";
	print OUT "echo $finish_string > $output_shell.sign\n";
	close OUT;
}

#==================== Display file  ==============================
#Description:
#	This Function is display files for specify the directory.
#	Input: specify the directory.
#	Output: return array of files.
#=================================================================
sub Display_file{
        my ($d,$f,@dirs,$basedir,@files);
        $basedir = $_[0];
        @dirs = ($basedir);
        die "error $basedir: $!" unless(-d $basedir);
        while(@dirs){
                $d = $dirs[0];
                $d .= "/" unless($d=~/\/$/);
                opendir Dir, $d || die "Can not open $d directory\n";
                my @filelist = readdir Dir;
                closedir Dir;
               my $f;
                foreach (@filelist){
                        $f = $d.$_;
                        if($_ eq "." || $_ eq ".."){
                        next;
                }
                push(@dirs, $f) if(-d $f);
                push(@files,$f);
                }
                shift @dirs;
        }
        return @files;
}

#==================== Thousands  ==============================
#Description:
#	Thie Function is Calculation of Thousands.
#	Input: a number list.
#	Output: a number list of Thousands.
#	eg: @StatLength = ToolKit::Thousands(@StatLength);
#==============================================================
sub Thousands{
	my (@Thousands); 
	foreach my $data (@_){
		my (@new_data,$new_data,@data,$i,$int,$decimals);
		($int,$decimals) = (split /\./,$data);
		@data = split //,$int;
		@data = reverse @data;
		my $temp =0;
		foreach  $i (@data){
			if($temp <3){
				push @new_data,$i;
			}else{
				push @new_data,",";
				push @new_data,$i;
				$temp = 0;
			}
			$temp++;
		}
		@new_data = reverse @new_data;
		$new_data = join '',@new_data;
		if($decimals){
			$new_data = $new_data . "." . $decimals;
		}
		push @Thousands,$new_data;
	}
		return @Thousands;
}

#==================== Thousands  ==============================
#Description:
#       Thie Function is Calculation of format Decimal Places.
#       Input: a number list.
#       Output: a number list of format decimal places.
#	eg: ($average) = ToolKit::DecimalPlaces("2",$average);
#==============================================================
sub DecimalPlaces{
	my (@DecimalPlaces,$place,$magnitude,$temp,$new_data,$length,$diff,$new_int,$new_magnitude,@new_magnitude);
	$place = shift @_;
	$magnitude = 1;
	foreach (1..$place){
		$magnitude = $magnitude * 10;
	}
	foreach my $data (@_){
		$temp = int($data * $magnitude);
		$new_data = $temp / $magnitude;
		($new_int,$new_magnitude) = split /\./,$new_data;
		if($new_magnitude){
			$length  = length $new_magnitude;
			@new_magnitude = split //,$new_magnitude;
		}else{
			$length  = 0;
			@new_magnitude = (); 
		}
		if ( $length < $place){
			$diff = $place - $length;
			foreach (1..$diff){
				push @new_magnitude,"0";
			}
			$new_magnitude = join '',@new_magnitude;
		}
		$new_data = $new_int . "." . $new_magnitude;
		push @DecimalPlaces,$new_data;
	}
	return @DecimalPlaces;
}


#==================== Read Conf File  =========================
#Description:
#       This Function is read config file.
#       Input: config file.
#       Output: return a hash.
#==============================================================
sub ReadConf{
        my ($confFile) = @_;
        my %Conf;
        open IN, $confFile or die "Cannot open file $confFile:$!\n";
        while (<IN>){
                chomp;
                next if(/^\s*$/ || /^\s*\#/);
                $_ =~ s/^\s*//;
                $_ =~ s/#(.)*//;
                $_ =~ s/\s*$//;
                if (/^(\w+)\s*=\s*(.*)$/xms) {
                        next if ($2 =~ /^\s*$/);
                        my $key = $1;
                        my $value = $2;
                        $value =~ s/\s*$//;
                        $Conf{$key} = $value;
                }
        }
        return %Conf;
}

#=================================================================
1;
__END__
