import "dart:math";

const List<String> natureWords = [
  'Moss',
  'Pine',
  'River',
  'Cloud',
  'Stone',
  'Leaf',
  'Fern',
  'Breeze',
  'Rain',
  'Thunder',
  'Petal',
  'Cactus',
  'Volcano',
  'Lagoon',
  'Dune',
  'Frost',
  'Blossom',
  'Tide',
  'Willow',
  'Sunbeam',
  'Pebble',
  'Coral',
  'Drizzle',
  'Meadow',
  'Glacier',
  'Twig',
  'Vine',
  'Grove',
  'Flame',
  'Aurora',
];

const List<String> techWords = [
  'Pixel',
  'Circuit',
  'Bot',
  'Nano',
  'Byte',
  'Cloud',
  'Laser',
  'Chip',
  'Drone',
  'Quantum',
  'Turbo',
  'Crypto',
  'Neon',
  'Signal',
  'WiFi',
  'Modem',
  'Server',
  'Code',
  'Syntax',
  'Kernel',
  'Cache',
  'Script',
  'Logic',
  'Sensor',
  'Matrix',
  'Fiber',
  'AI',
  'Data',
  'Glitch',
  'Hack',
];

String naime() {
  int first = Random().nextInt(30);
  int second = Random().nextInt(30);

  String name = "${techWords[first]}${natureWords[second]}";

  return "$name|$first|$second";
}
