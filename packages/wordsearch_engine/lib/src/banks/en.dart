// DRAFT · pending review by a native speaker (task P-07).
//
// Criteria for this draft:
// - words a general audience knows, US spelling;
// - no words that contain or suggest profanity (cock-, tit-, booby, hoe,
//   screw, beaver, woodpecker…);
// - one word, no spaces or hyphens; 3 to 14 letters.
import 'word_theme.dart';

const englishThemes = <WordTheme>[
  WordTheme('frutas', 'Fruit', [
    'apple', 'apricot', 'avocado', 'banana', 'blackberry', 'blueberry', 'cantaloupe', 'cherry', 'clementine', //
    'coconut', 'cranberry', 'currant', 'date', 'dragonfruit', 'elderberry', 'fig', 'gooseberry', 'grape',
    'grapefruit', 'guava', 'honeydew', 'jackfruit', 'kiwi', 'kumquat', 'lemon', 'lime', 'lychee', 'mandarin',
    'mango', 'melon', 'mulberry', 'nectarine', 'olive', 'orange', 'papaya', 'passionfruit', 'peach', 'pear',
    'persimmon', 'pineapple', 'plantain', 'plum', 'pomegranate', 'quince', 'raisin', 'raspberry', 'rhubarb',
    'starfruit', 'strawberry', 'tangerine', 'watermelon', 'almond', 'cashew', 'chestnut', 'hazelnut',
    'pecan', 'pistachio', 'walnut', 'acorn', 'prune', 'boysenberry',
  ]),
  WordTheme('verduras', 'Vegetables', [
    'artichoke', 'arugula', 'asparagus', 'bean', 'beet', 'broccoli', 'cabbage', 'carrot', 'cauliflower', //
    'celery', 'chard', 'chickpea', 'chive', 'corn', 'cucumber', 'eggplant', 'endive', 'fennel', 'garlic',
    'ginger', 'kale', 'leek', 'lentil', 'lettuce', 'mushroom', 'okra', 'onion', 'parsnip', 'pea', 'pepper',
    'potato', 'pumpkin', 'radish', 'rutabaga', 'shallot', 'spinach', 'sprout', 'squash', 'tomato', 'turnip',
    'watercress', 'yam', 'zucchini', 'kohlrabi', 'cassava', 'soybean', 'scallion', 'jalapeno', 'basil',
    'cilantro', 'oregano', 'parsley', 'rosemary', 'thyme', 'mint', 'dill', 'sage', 'tarragon', 'caper',
    'horseradish', 'celeriac',
  ]),
  WordTheme('granja', 'On the Farm', [
    'cow', 'bull', 'calf', 'heifer', 'horse', 'mare', 'foal', 'pony', 'donkey', 'mule', 'sheep', 'lamb', 'ram', //
    'goat', 'kid', 'pig', 'piglet', 'hen', 'rooster', 'chick', 'duck', 'duckling', 'goose', 'turkey',
    'rabbit', 'dog', 'cat', 'quail', 'alpaca', 'llama', 'buffalo', 'herd', 'flock', 'stable', 'barn',
    'pasture', 'meadow', 'farmer', 'shepherd', 'tractor', 'hay', 'straw', 'trough', 'windmill', 'orchard',
    'silo', 'milk', 'cheese', 'wool', 'plow', 'harvest', 'wheat', 'barley', 'oats', 'scarecrow', 'pigsty',
    'saddle', 'horseshoe', 'fence', 'gate', 'combine', 'beehive', 'coop', 'paddock',
  ]),
  WordTheme('salvajes', 'Wild Animals', [
    'lion', 'tiger', 'elephant', 'giraffe', 'zebra', 'rhinoceros', 'hippo', 'gorilla', 'chimpanzee', //
    'orangutan', 'monkey', 'leopard', 'cheetah', 'jaguar', 'cougar', 'panther', 'lynx', 'bobcat', 'wolf',
    'fox', 'bear', 'panda', 'koala', 'kangaroo', 'camel', 'deer', 'moose', 'elk', 'reindeer', 'gazelle',
    'antelope', 'bison', 'boar', 'hyena', 'jackal', 'raccoon', 'otter', 'squirrel', 'hedgehog', 'mole',
    'badger', 'armadillo', 'sloth', 'tapir', 'okapi', 'meerkat', 'mongoose', 'weasel', 'ferret', 'hare', 'bat',
    'crocodile', 'alligator', 'snake', 'cobra', 'python', 'iguana', 'chameleon', 'tortoise', 'lizard', 'frog',
    'toad', 'salamander', 'coyote', 'ocelot', 'marmot', 'chinchilla', 'porcupine', 'skunk', 'opossum',
    'wolverine',
  ]),
  WordTheme('aves', 'Birds', [
    'eagle', 'falcon', 'hawk', 'owl', 'condor', 'vulture', 'crow', 'raven', 'magpie', 'sparrow', 'swallow', //
    'canary', 'finch', 'nightingale', 'blackbird', 'robin', 'hummingbird', 'parrot', 'macaw', 'toucan',
    'pelican', 'seagull', 'albatross', 'flamingo', 'stork', 'heron', 'crane', 'penguin', 'ostrich', 'emu',
    'pheasant', 'partridge', 'quail', 'pigeon', 'dove', 'swan', 'duck', 'goose', 'turkey', 'lark', 'swift',
    'starling', 'cormorant', 'puffin', 'quetzal', 'parakeet', 'kiwi', 'kite', 'osprey', 'kestrel', 'plover',
    'jay', 'oriole', 'cardinal', 'bluebird', 'wren', 'warbler', 'kingfisher', 'egret', 'ibis', 'sandpiper',
    'mallard', 'loon', 'grouse',
  ]),
  WordTheme('mar', 'Under the Sea', [
    'whale', 'dolphin', 'shark', 'orca', 'walrus', 'seal', 'octopus', 'squid', 'cuttlefish', 'jellyfish', //
    'crab', 'lobster', 'shrimp', 'prawn', 'mussel', 'oyster', 'snail', 'urchin', 'coral', 'sponge', 'anemone',
    'fish', 'tuna', 'sardine', 'salmon', 'cod', 'hake', 'eel', 'stingray', 'manta', 'halibut', 'flounder',
    'grouper', 'snapper', 'mackerel', 'anchovy', 'herring', 'marlin', 'swordfish', 'barracuda', 'moray',
    'turtle', 'manatee', 'narwhal', 'krill', 'plankton', 'seaweed', 'kelp', 'reef', 'wave', 'tide', 'beach',
    'sand', 'shore', 'lighthouse', 'harbor', 'starfish', 'seahorse', 'clam', 'scallop', 'barnacle', 'pufferfish',
    'clownfish', 'trout',
  ]),
  WordTheme('insectos', 'Bugs and Insects', [
    'ant', 'bee', 'wasp', 'bumblebee', 'fly', 'mosquito', 'butterfly', 'moth', 'dragonfly', 'grasshopper', //
    'cricket', 'cicada', 'beetle', 'ladybug', 'firefly', 'glowworm', 'termite', 'flea', 'louse', 'bedbug',
    'tick', 'spider', 'scorpion', 'centipede', 'millipede', 'earthworm', 'snail', 'slug', 'caterpillar',
    'worm', 'larva', 'pupa', 'chrysalis', 'cocoon', 'hive', 'honeycomb', 'anthill', 'mantis', 'earwig',
    'weevil', 'hornet', 'gnat', 'mayfly', 'aphid', 'locust', 'mite', 'tarantula', 'cobweb', 'antenna', 'wing',
    'stinger', 'nectar', 'pollen', 'swarm', 'drone', 'colony', 'metamorphosis', 'insect', 'katydid', 'stinkbug',
    'silkworm', 'damselfly',
  ]),
  WordTheme('cocina', 'Kitchen Things', [
    'spoon', 'knife', 'fork', 'plate', 'glass', 'cup', 'mug', 'bowl', 'pot', 'pan', 'skillet', 'saucepan', //
    'kettle', 'teapot', 'jug', 'pitcher', 'bottle', 'strainer', 'colander', 'funnel', 'grater', 'mixer',
    'blender', 'toaster', 'oven', 'microwave', 'fridge', 'freezer', 'sink', 'faucet', 'stove', 'grill',
    'griddle', 'tray', 'platter', 'cleaver', 'sieve', 'whisk', 'spatula', 'ladle', 'tongs', 'scissors',
    'opener', 'sifter', 'napkin', 'tablecloth', 'apron', 'thermos', 'mortar', 'pestle', 'scale', 'saltshaker',
    'dishwasher', 'cutlery', 'saucer', 'teacup', 'casserole', 'wok', 'peeler', 'juicer', 'timer', 'cupboard',
    'pantry', 'lid', 'chopsticks',
  ]),
  WordTheme('comidas', 'Food', [
    'bread', 'rice', 'pasta', 'soup', 'salad', 'omelet', 'pizza', 'burger', 'sandwich', 'taco', 'burrito', //
    'noodles', 'lasagna', 'spaghetti', 'meatball', 'stew', 'chili', 'curry', 'steak', 'chicken', 'fish',
    'bacon', 'ham', 'cheese', 'butter', 'yogurt', 'cookie', 'cake', 'pie', 'muffin', 'cupcake', 'brownie',
    'pudding', 'custard', 'icecream', 'chocolate', 'candy', 'caramel', 'jam', 'honey', 'cereal', 'oatmeal',
    'granola', 'pancake', 'waffle', 'donut', 'bagel', 'pretzel', 'popcorn', 'toast', 'juice', 'smoothie',
    'milkshake', 'coffee', 'tea', 'lemonade', 'sushi', 'dumpling', 'risotto', 'quiche', 'nachos', 'gravy',
    'salsa', 'ketchup', 'mustard', 'mayonnaise', 'casserole', 'biscuit', 'croissant',
  ]),
  WordTheme('profesiones', 'Jobs', [
    'doctor', 'dentist', 'nurse', 'teacher', 'lawyer', 'judge', 'engineer', 'architect', 'firefighter', //
    'police', 'carpenter', 'plumber', 'electrician', 'mechanic', 'baker', 'butcher', 'farmer', 'chef', 'cook',
    'waiter', 'courier', 'driver', 'pilot', 'astronaut', 'scientist', 'chemist', 'biologist', 'veterinarian',
    'pharmacist', 'psychologist', 'accountant', 'economist', 'programmer', 'designer', 'photographer',
    'painter', 'sculptor', 'writer', 'poet', 'actor', 'musician', 'dancer', 'singer', 'hairdresser', 'barber',
    'tailor', 'jeweler', 'gardener', 'florist', 'librarian', 'translator', 'interpreter', 'sailor', 'fisher',
    'miner', 'cashier', 'secretary', 'journalist', 'reporter', 'artist', 'guide', 'manager', 'receptionist',
    'janitor', 'lifeguard', 'coach', 'surgeon', 'paramedic', 'editor', 'banker', 'clerk',
  ]),
  WordTheme('deportes', 'Sports', [
    'soccer', 'football', 'basketball', 'baseball', 'tennis', 'volleyball', 'handball', 'rugby', 'golf', //
    'hockey', 'boxing', 'judo', 'karate', 'taekwondo', 'fencing', 'swimming', 'diving', 'surfing', 'rowing',
    'sailing', 'canoeing', 'cycling', 'running', 'marathon', 'triathlon', 'gymnastics', 'skating', 'skiing',
    'snowboard', 'climbing', 'hiking', 'riding', 'polo', 'cricket', 'badminton', 'squash', 'billiards',
    'bowling', 'chess', 'darts', 'archery', 'wrestling', 'weightlifting', 'karting', 'lacrosse', 'softball',
    'ball', 'racket', 'net', 'goal', 'referee', 'stadium', 'court', 'medal', 'trophy', 'team', 'player',
    'race', 'jump', 'javelin', 'discus', 'relay', 'hurdles', 'pitch', 'umpire', 'helmet',
  ]),
  WordTheme('musica', 'Music', [
    'guitar', 'piano', 'violin', 'viola', 'cello', 'harp', 'flute', 'clarinet', 'oboe', 'bassoon', //
    'saxophone', 'trumpet', 'trombone', 'tuba', 'drum', 'drums', 'cymbal', 'xylophone', 'marimba', 'maracas',
    'tambourine', 'castanets', 'triangle', 'accordion', 'harmonica', 'organ', 'keyboard', 'synthesizer',
    'ukulele', 'banjo', 'mandolin', 'lute', 'bagpipes', 'bongo', 'conga', 'bell', 'whistle', 'ocarina',
    'melody', 'rhythm', 'harmony', 'note', 'chord', 'song', 'orchestra', 'band', 'choir', 'concert',
    'conductor', 'tempo', 'staff', 'clef', 'beat', 'tune', 'lyrics', 'chorus', 'verse', 'opera', 'symphony',
    'piccolo', 'harpsichord', 'metronome', 'microphone', 'record',
  ]),
  WordTheme('ropa', 'Clothes', [
    'shirt', 'blouse', 'pants', 'jeans', 'shorts', 'skirt', 'dress', 'jacket', 'coat', 'vest', 'sweater', //
    'hoodie', 'cardigan', 'scarf', 'glove', 'mitten', 'beanie', 'hat', 'cap', 'beret', 'sock', 'tights',
    'shoe', 'sneaker', 'boot', 'sandal', 'slipper', 'pajamas', 'robe', 'swimsuit', 'tie', 'belt', 'bandana',
    'handbag', 'backpack', 'purse', 'wallet', 'watch', 'bracelet', 'necklace', 'ring', 'earring', 'glasses',
    'sunglasses', 'umbrella', 'raincoat', 'uniform', 'suit', 'tuxedo', 'overalls', 'cape', 'poncho', 'kimono',
    'tunic', 'tracksuit', 'button', 'zipper', 'pocket', 'collar', 'sleeve', 'apron', 'bowtie', 'blazer',
    'parka', 'loafer',
  ]),
  WordTheme('casa', 'Around the House', [
    'door', 'window', 'roof', 'ceiling', 'wall', 'floor', 'stairs', 'hallway', 'kitchen', 'cabinet', 'stool', //
    'bedroom', 'bathroom', 'shower', 'bathtub', 'sink', 'mirror', 'closet', 'drawer', 'shelf', 'bookcase',
    'table', 'chair', 'sofa', 'couch', 'armchair', 'bed', 'pillow', 'sheet', 'blanket', 'mattress', 'curtain',
    'rug', 'carpet', 'lamp', 'basement', 'attic', 'garage', 'garden', 'porch', 'balcony', 'fireplace',
    'doorbell', 'mailbox', 'key', 'lock', 'doorstep', 'outlet', 'switch', 'lightbulb', 'blinds', 'radiator',
    'heater', 'fan', 'crib', 'dresser', 'nightstand', 'painting', 'doormat', 'patio', 'chimney', 'cushion',
    'vase', 'quilt', 'hammock',
  ]),
  WordTheme('herramientas', 'Tools', [
    'hammer', 'nail', 'bolt', 'rivet', 'washer', 'wrench', 'pliers', 'saw', 'hacksaw', 'drill', 'bit', //
    'sandpaper', 'plane', 'chisel', 'square', 'level', 'tape', 'ruler', 'compass', 'shovel', 'spade', 'rake',
    'axe', 'hatchet', 'machete', 'shears', 'pruner', 'mower', 'wheelbarrow', 'ladder', 'scaffold', 'trowel',
    'brush', 'roller', 'glue', 'hinge', 'staple', 'stapler', 'flashlight', 'hose', 'bucket', 'rope', 'pulley',
    'lever', 'mallet', 'sledgehammer', 'file', 'awl', 'lathe', 'anvil', 'vise', 'clamp', 'crowbar',
    'pickaxe', 'toolbox', 'jigsaw', 'chainsaw', 'pitchfork', 'trimmer', 'sander', 'caulk', 'putty',
  ]),
  WordTheme('transportes', 'Getting Around', [
    'car', 'truck', 'bus', 'van', 'minivan', 'pickup', 'taxi', 'motorcycle', 'scooter', 'bicycle', 'bike', //
    'skateboard', 'train', 'subway', 'tram', 'trolley', 'cablecar', 'airplane', 'jet', 'glider',
    'helicopter', 'balloon', 'blimp', 'rocket', 'spaceship', 'ship', 'boat', 'motorboat', 'sailboat', 'yacht',
    'liner', 'ferry', 'canoe', 'kayak', 'raft', 'submarine', 'freighter', 'tugboat', 'tractor', 'ambulance',
    'bulldozer', 'excavator', 'carriage', 'wagon', 'sled', 'sleigh', 'camper', 'limousine', 'jeep', 'tricycle',
    'seaplane', 'gondola', 'catamaran', 'chairlift', 'locomotive', 'caboose', 'stagecoach', 'hovercraft',
    'forklift', 'monorail', 'unicycle', 'rickshaw',
  ]),
  WordTheme('naturaleza', 'Landscapes', [
    'mountain', 'hill', 'valley', 'river', 'lake', 'pond', 'sea', 'ocean', 'beach', 'coast', 'island', //
    'peninsula', 'bay', 'gulf', 'cape', 'cliff', 'cave', 'grotto', 'volcano', 'crater', 'glacier', 'desert',
    'dune', 'oasis', 'jungle', 'forest', 'woods', 'rainforest', 'prairie', 'plain', 'plateau', 'savanna',
    'tundra', 'steppe', 'swamp', 'marsh', 'spring', 'waterfall', 'stream', 'creek', 'canyon', 'gorge', 'ridge',
    'summit', 'peak', 'slope', 'rock', 'stone', 'sand', 'soil', 'mud', 'moss', 'fern', 'root', 'leaf',
    'branch', 'trunk', 'reef', 'delta', 'estuary', 'fjord', 'geyser', 'archipelago', 'horizon', 'landscape',
    'meadow', 'lagoon', 'boulder',
  ]),
  WordTheme('clima', 'Weather', [
    'sun', 'rain', 'cloud', 'wind', 'snow', 'hail', 'fog', 'mist', 'dew', 'frost', 'ice', 'storm', 'thunder', //
    'lightning', 'hurricane', 'tornado', 'cyclone', 'typhoon', 'monsoon', 'blizzard', 'breeze', 'gust',
    'shower', 'downpour', 'drizzle', 'flood', 'drought', 'heat', 'cold', 'temperature', 'humidity', 'pressure',
    'thermometer', 'barometer', 'forecast', 'season', 'spring', 'summer', 'autumn', 'fall', 'winter',
    'rainbow', 'aurora', 'eclipse', 'sunrise', 'sunset', 'dusk', 'dawn', 'twilight', 'cloudy', 'sunny',
    'rainy', 'windy', 'snowy', 'foggy', 'stormy', 'icicle', 'sleet', 'thaw', 'heatwave', 'climate',
    'snowflake', 'puddle', 'umbrella', 'tempest',
  ]),
  WordTheme('cuerpo', 'The Human Body', [
    'head', 'face', 'forehead', 'eyebrow', 'eyelash', 'eye', 'nose', 'mouth', 'lip', 'tooth', 'tongue', 'ear', //
    'cheek', 'chin', 'jaw', 'neck', 'shoulder', 'arm', 'elbow', 'wrist', 'hand', 'finger', 'thumb', 'chest',
    'back', 'waist', 'hip', 'leg', 'knee', 'ankle', 'foot', 'heel', 'toe', 'heart', 'lung', 'liver',
    'kidney', 'stomach', 'brain', 'bone', 'muscle', 'skin', 'blood', 'vein', 'artery', 'skeleton', 'skull',
    'spine', 'rib', 'throat', 'navel', 'hair', 'palm', 'thigh', 'calf', 'esophagus', 'intestine', 'tendon',
    'neuron', 'eyelid', 'knuckle', 'fingernail', 'forearm', 'shin', 'pupil', 'eardrum', 'temple',
  ]),
  WordTheme('colores', 'Colors', [
    'red', 'blue', 'green', 'yellow', 'orange', 'purple', 'violet', 'pink', 'white', 'black', 'gray', 'brown', //
    'beige', 'gold', 'silver', 'turquoise', 'maroon', 'indigo', 'lilac', 'magenta', 'fuchsia', 'ochre',
    'cream', 'crimson', 'vermilion', 'emerald', 'coral', 'salmon', 'cyan', 'amber', 'ivory', 'olive', 'khaki',
    'burgundy', 'scarlet', 'copper', 'bronze', 'pearl', 'lavender', 'mauve', 'mustard', 'caramel',
    'chocolate', 'vanilla', 'mint', 'aquamarine', 'sapphire', 'ruby', 'sienna', 'sepia', 'terracotta', 'ash',
    'charcoal', 'sand', 'cinnamon', 'navy', 'teal', 'lime', 'plum', 'peach', 'tan', 'jade', 'cobalt',
    'periwinkle', 'chartreuse', 'mahogany',
  ]),
];

/// Words the grid must never form on its own (filler or crossings).
/// Normalized or not: the engine normalizes them.
const englishBlocklist = <String>{
  'fuck', 'fucks', 'fucker', 'shit', 'shits', 'cunt', 'cock', 'dick', 'dicks', 'piss', 'twat', 'slut', //
  'whore', 'bitch', 'bastard', 'wank', 'wanker', 'crap', 'arse', 'ass', 'tits', 'boob', 'boobs', 'penis',
  'vagina', 'anus', 'anal', 'porn', 'sex', 'sexy', 'rape', 'nazi', 'cum', 'fag', 'fags', 'faggot', 'nigger',
  'nigga', 'retard', 'kike', 'spic', 'homo', 'dildo', 'jizz', 'puss', 'pussy', 'hitler', 'dyke',
};
