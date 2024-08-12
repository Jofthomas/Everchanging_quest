extends Node
class_name LogManager

var log : Array[String] = []

func add_entry(text: String):
	log.push_back(text)
