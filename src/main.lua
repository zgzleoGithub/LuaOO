--[[
  @brief  面向对象机制模拟实现
      原理简介：这种实现机制有个很明确的概念，那就是我们只能用class函数类生产一个类，我们可以定义类的方法，但是如果我们想使用类的方法，
      必须通过new的操作来获取一个该类的对象，通过该对象调用。这就是一个实例化的过程，完全模拟了其他语言中面向对象的特性，很好的阐述了了类和对象的关系：
      对象是一个类的实例。
     在class函数的实现中，中心思想是把我们要生成的对象放在_class这个表中，而索引这个值的key就是class_type（可以理解为类名）,而值就是函数中的vtbl表；
  class_type是函数要返回的对象，实际上就是我们定义的类。而可以看到这个类（实际就是一个表）默认只有ctor(构造),super(父类),new(生成对象)三个元素，
  ctor是模拟的构造函数，默认为false的值，函数中有判断，为false，不会调用；super是模拟的父类，它明显也应该是一个表；new是生成对象的方法，我们就是使用new来生成对象的，
      函数中也定义了new函数的具体操作，可以看到，在new函数中如果构造不为假，会调用构造函数，如果super不为空，会传入super继续调用create，实际作用就是去调用super（父类）的。
  new返回的是一个新建空表obj，重要的是函数设置了obj的元表，把元表的__index复制为_class[class_type]，也就是vtbl。我们在使用obj的时候，所有没有的东西都会去vtbl表
      里面找。在函数的最后还设置了vtbl的元表，另其中__index等于一个函数，就是在vtbl找不到元素的时候会调用这个函数，而这个函数就是在super（父类）里面查找这个元素，找到后会赋给vtbl表
      并且返回这个元素。函数在后面还为class_type设置了元表，它设置了__newindex，意思就是在为class_type添加元素的时候都会调用__newindex,而在__newindex函数里面实际就是
      把原本要赋的值赋值给了vtbl表，这个元素实际上是在vtbl表里面，所以我们为自己生成的类添加元素的时候，之后并不能直接访问到，只能通过new的对象来访问（new的对象返回的是一个元表__index设置为vtbl表的空表）。
  
]]

local _class = {}                   --创建一个空表

function class(super) 
  local class_type = {}             --创建一个空表
  class_type.ctor = false           --构造函数为假（默认无构造）
  class_type.super = super          --基类为传入的对象，不传则为nil
  class_type.new = function (...)   --定义new函数，生成类的对象
    local obj = {}                  --创建一个空表，new生成的新对象就是这个表
    do
      local create                  --create函数用于在生成对象的时候调用该对象的构造函数（如果该对象有构造函数的话（默认为false））
      create = function (c,...)     --声明局部的create函数 等同于 local function create().....
        if c.super then             --
          create(c.super)           --如果传入的对象的基类不为空，递归调用create传入基类继续create,递归调用主要是保证能够调用到父类的构造
        end
        if c.ctor then              --
          c.ctor(obj,...)           --如果传入对象的构造不为空，调用该对象的构造函数
        end
      end
      create(class_type,...)        --调用create函数
    end

    setmetatable(obj,{ __index=_class[class_type] })      --设置obj的元表,__index赋值为_class[class_type]，即下文的vtbl，意义为：当在obj里找不到方法时都在vtbl里面找
    return obj
  end
  
  local vtbl={}                             --创建一个空表
  _class[class_type]=vtbl                   --把刚创建的空表存放在_class表的class_type下

  setmetatable(class_type,{__newindex=      --设置class_type的元表，覆盖了__newindex，每次在给class_type赋值时，都会执行vtbl[k]=v，实际上就是给表vtbl赋值
    function(t,k,v)
      vtbl[k]=v
    end
  })

  if super then                             --如果super不为空，设置vtbl的元表，再每次调用vtbl的方法的时候，如果没有就从super里找，找到后赋给vtbl，并返回该值
    setmetatable(vtbl,{__index=
      function(t,k)
        local ret=_class[super][k]          --所有通过class生成的类都是以自己的类为key值存放的，所以这可以通过super来索引出父类表
        vtbl[k]=ret
        return ret
      end
    })
  end

  return class_type
end



