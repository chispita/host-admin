<?php

class Fecha
{
	public static function hace($tm, $rcs = 0)
	{
		$cur_tm = time(); $dif = $cur_tm-$tm;
		$pds = array('segundo', 'minuto', 'hora', 'día', 'semana', 'mes', 'año', 'década');
		$lngh = array(1,60,3600,86400,604800,2630880,31570560,315705600);
		for($v = sizeof($lngh)-1; ($v >= 0)&&(($no = $dif/$lngh[$v])<=1); $v--); if($v < 0) $v = 0; $_tm = $cur_tm-($dif%$lngh[$v]);

		$no = floor($no); if($no <> 1) $pds[$v] .='s'; $x=sprintf("%d %s",$no,$pds[$v]);
		preg_replace("/mess/", "meses", $x);
		if(($rcs == 1)&&($v >= 1)&&(($cur_tm-$_tm) > 0)) $x .= time_ago($_tm);
		return $x;
	}
}

?>