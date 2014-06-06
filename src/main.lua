--[[
  @brief  ����������ģ��ʵ��
      ԭ���飺����ʵ�ֻ����и�����ȷ�ĸ���Ǿ�������ֻ����class����������һ���࣬���ǿ��Զ�����ķ������������������ʹ����ķ�����
      ����ͨ��new�Ĳ�������ȡһ������Ķ���ͨ���ö�����á������һ��ʵ�����Ĺ��̣���ȫģ�������������������������ԣ��ܺõĲ���������Ͷ���Ĺ�ϵ��
      ������һ�����ʵ����
     ��class������ʵ���У�����˼���ǰ�����Ҫ���ɵĶ������_class������У����������ֵ��key����class_type���������Ϊ������,��ֵ���Ǻ����е�vtbl��
  class_type�Ǻ���Ҫ���صĶ���ʵ���Ͼ������Ƕ�����ࡣ�����Կ�������ࣨʵ�ʾ���һ����Ĭ��ֻ��ctor(����),super(����),new(���ɶ���)����Ԫ�أ�
  ctor��ģ��Ĺ��캯����Ĭ��Ϊfalse��ֵ�����������жϣ�Ϊfalse��������ã�super��ģ��ĸ��࣬������ҲӦ����һ����new�����ɶ���ķ��������Ǿ���ʹ��new�����ɶ���ģ�
      ������Ҳ������new�����ľ�����������Կ�������new������������첻Ϊ�٣�����ù��캯�������super��Ϊ�գ��ᴫ��super��������create��ʵ�����þ���ȥ����super�����ࣩ�ġ�
  new���ص���һ���½��ձ�obj����Ҫ���Ǻ���������obj��Ԫ����Ԫ���__index����Ϊ_class[class_type]��Ҳ����vtbl��������ʹ��obj��ʱ������û�еĶ�������ȥvtbl��
      �����ҡ��ں��������������vtbl��Ԫ��������__index����һ��������������vtbl�Ҳ���Ԫ�ص�ʱ������������������������������super�����ࣩ����������Ԫ�أ��ҵ���ḳ��vtbl��
      ���ҷ������Ԫ�ء������ں��滹Ϊclass_type������Ԫ����������__newindex����˼������Ϊclass_type���Ԫ�ص�ʱ�򶼻����__newindex,����__newindex��������ʵ�ʾ���
      ��ԭ��Ҫ����ֵ��ֵ����vtbl�����Ԫ��ʵ��������vtbl�����棬��������Ϊ�Լ����ɵ������Ԫ�ص�ʱ��֮�󲢲���ֱ�ӷ��ʵ���ֻ��ͨ��new�Ķ��������ʣ�new�Ķ��󷵻ص���һ��Ԫ��__index����Ϊvtbl��Ŀձ���
  
]]

local _class = {}                   --����һ���ձ�

function class(super) 
  local class_type = {}             --����һ���ձ�
  class_type.ctor = false           --���캯��Ϊ�٣�Ĭ���޹��죩
  class_type.super = super          --����Ϊ����Ķ��󣬲�����Ϊnil
  class_type.new = function (...)   --����new������������Ķ���
    local obj = {}                  --����һ���ձ�new���ɵ��¶�����������
    do
      local create                  --create�������������ɶ����ʱ����øö���Ĺ��캯��������ö����й��캯���Ļ���Ĭ��Ϊfalse����
      create = function (c,...)     --�����ֲ���create���� ��ͬ�� local function create().....
        if c.super then             --
          create(c.super)           --�������Ķ���Ļ��಻Ϊ�գ��ݹ����create����������create,�ݹ������Ҫ�Ǳ�֤�ܹ����õ�����Ĺ���
        end
        if c.ctor then              --
          c.ctor(obj,...)           --����������Ĺ��첻Ϊ�գ����øö���Ĺ��캯��
        end
      end
      create(class_type,...)        --����create����
    end

    setmetatable(obj,{ __index=_class[class_type] })      --����obj��Ԫ��,__index��ֵΪ_class[class_type]�������ĵ�vtbl������Ϊ������obj���Ҳ�������ʱ����vtbl������
    return obj
  end
  
  local vtbl={}                             --����һ���ձ�
  _class[class_type]=vtbl                   --�Ѹմ����Ŀձ�����_class���class_type��

  setmetatable(class_type,{__newindex=      --����class_type��Ԫ��������__newindex��ÿ���ڸ�class_type��ֵʱ������ִ��vtbl[k]=v��ʵ���Ͼ��Ǹ���vtbl��ֵ
    function(t,k,v)
      vtbl[k]=v
    end
  })

  if super then                             --���super��Ϊ�գ�����vtbl��Ԫ����ÿ�ε���vtbl�ķ�����ʱ�����û�оʹ�super���ң��ҵ��󸳸�vtbl�������ظ�ֵ
    setmetatable(vtbl,{__index=
      function(t,k)
        local ret=_class[super][k]          --����ͨ��class���ɵ��඼�����Լ�����Ϊkeyֵ��ŵģ����������ͨ��super�������������
        vtbl[k]=ret
        return ret
      end
    })
  end

  return class_type
end



