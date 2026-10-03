import { encodeCrosshair } from 'csgo-sharecode';

const crosshair = {
	format: 'cs2-v1',
	style: 2,
	followRecoil: false,
	centerDotEnabled: true,
	tStyleEnabled: false,
	outlineMode: 0,
	red: 255,
	green: 0,
	blue: 0,
	alpha: 255,
	outlineRed: 0,
	outlineGreen: 0,
	outlineBlue: 0,
	outlineAlpha: 255,
	gap: 0,
	length: 5,
	thickness: 1,
	dynamicSpreadLimit: 181,
	splitDistance: 3,
	innerSplitAlpha: 1,
	outerSplitAlpha: 0.35,
	splitSizeRatio: 0,
	screenHeight: 768,
	scopeDotScale: 1,
	scopeDotUseCrosshairColor: false,
};

const shareCode = encodeCrosshair(crosshair);
console.log(shareCode);
