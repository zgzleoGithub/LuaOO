require("main")


FatherClass = class()

function FatherClass.say()
  print("Hello")
end

function FatherClass.ctor()
	print("ctor father")
end

SonClass = class(FatherClass)

function SonClass.ctor()
	print("ctor son")
end

son = SonClass.new()
son.say()