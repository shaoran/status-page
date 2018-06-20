module StatusPage

  class Query
    def initialize(args={})
      @args = args.dup
    end

    def filter(obj)
      _filter obj
    end

  end


  class AndQuery < Query

    def _filter(obj)
      ret = true

      @args.each do |key,val|
        next if ret == false
        if val.is_a? Query
          ret = ret && val.filter(obj)
        else

          if obj.include?(key)
            v = obj[key]
          elsif obj.include?(key.to_sym)
            v = obj[key.to_sym]
          else
            ret = false
            next
          end

          ret = false if v != val

        end
      end

      ret
    end

  end

  class OrQuery < Query
    def _filter(obj)
      ret = false

      @args.each do |key,val|
        next if ret == true
        if val.is_a? Query
          r = val.filter(obj)
          ret = ret || r
        else

          if obj.include?(key)
            v = obj[key]
          elsif obj.include?(key.to_sym)
            v = obj[key.to_sym]
          else
            next
          end

          ret = true if v == val

        end
      end

      ret
    end
  end

  class NotQuery < Query
    def _filter(obj)
      return !@args.filter(obj) if @args.is_a?(Query)

      q = AndQuery.new(@args)

      return !q.filter(obj)
    end
  end


end



def _QAND(args)
  return StatusPage::AndQuery.new args
end

def _QOR(args)
  return StatusPage::OrQuery.new args
end

def _QNOT(args)
  return StatusPage::NotQuery.new args
end
