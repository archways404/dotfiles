import { decodeCrosshairShareCode, crosshairToConVars } from 'csgo-sharecode';

const shareCode = 'CSbTELhNsQkoPiMqWx3BnJ4eBQaH9JbCHdKGJ54t8WQGzC';
const crosshair = decodeCrosshairShareCode(shareCode);
const conVars = crosshairToConVars(crosshair);
console.log(conVars);
// Output:
//
// cl_crosshair_drawoutline "0"
// cl_crosshair_dynamic_maxdist_splitratio "0"
// cl_crosshair_dynamic_splitalpha_innermod "1"
// cl_crosshair_dynamic_splitalpha_outermod "0.35"
// cl_crosshair_dynamic_splitdist "3"
// cl_crosshair_dynamic_spread_limit "181"
// cl_crosshair_gap "0"
// cl_crosshair_length "5"
// cl_crosshair_recoil "0"
// cl_crosshair_screen_height "768"
// cl_crosshair_t "0"
// cl_crosshair_thickness "1"
// cl_crosshaircolor_a "255"
// cl_crosshaircolor_b "0"
// cl_crosshaircolor_g "0"
// cl_crosshaircolor_r "255"
// cl_crosshairdot "1"
// cl_crosshairoutline_a "255"
// cl_crosshairoutline_b "0"
// cl_crosshairoutline_g "0"
// cl_crosshairoutline_r "0"
// cl_crosshairstyle "2"
// cl_ironsight_dot_scale "1"
// cl_ironsight_usecrosshaircolor "0"
