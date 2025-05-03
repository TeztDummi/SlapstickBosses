extends MeshInstance3D

var texts = [
	"Drink my copyright free carbonated beverage!",
	"Soda-Sola™ is not affiliated with any other soda companys!",
	"I exist to sell!",
	"Gulp down my bubbly sugar water!",
	"I forgot my name when they redesigned me in 2012!",
	"Don't drink water!",
	"Try the new Sola-o's Cereal™!",
	"My fur is plastic!",
	"Made you look!",
	"Stop reading signs, you're playing a game!",
	"Did you know: Soda-Sola™ tastes good and makes you happy!",
	"Did you know: Pressurized liquid is bad for you!",
	"Did you know: The average human drowns within 10 minutes!",
	"Soda-Sola™ has 1000 mg of caffine per 12 oz!",
	"Soda-Sola™ is not responsable for injury or death due to mixture with mints!",
	"The Sherman Antitrust Act of 1890 sucks!",
]
# Called when the node enters the scene tree for the first time.
func _ready():
	$SubViewport/Label.text = texts.pick_random()
	
	if has_meta("custom"): $SubViewport/Label.text = get_meta("custom")
