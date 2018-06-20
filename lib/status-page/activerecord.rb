require "fileutils"
require "status-page/query"
require "json"

module StatusPage

  class SavingDeleted < Exception
  end

  class ActiveRecord

    class << self; attr_accessor :wholedata end

    @@db_base = File.join(Dir.home, ".config", "status-page", "db")

    def self.db_base=(path)
      @@db_base = path
    end

    def self.db_base
      @@db_base
    end

    def self.reload_cache
      FileUtils.mkdir_p(@@db_base)

      fn = self.get_store_fn

      @wholedata = []

      if File.exists?(fn)
        cnt = File.read(fn)

        @wholedata = JSON.load(cnt)
      else
        self.save(@wholedata)
      end
    end

    def self.get_store_fn
      klass = self.name.split('::').last

      File.join(@@db_base, "#{klass}.json")
    end

    def self.save(obj)
      fn = self.get_store_fn
      cnt = obj.to_json
      begin
        File.open(fn, "w") { |f| f.write(cnt) }
      rescue
        return false
      end

      true
    end

    def self.all
      @wholedata.map do |data|
        self.new(data, true)
      end
    end

    def self.find(query={})
      ret = []
      query = _QAND(query) if query.is_a? Hash

      @wholedata.each do |data|


        ret << self.new(data, true) if query.filter(data)
      end

      ret
    end


    def initialize(args = {}, cached = false)
      @data = args.dup
      @cached = cached
      @orig = nil
      @orig = args if @cached

      @dirty = false
      @dirty = true unless cached
      @deleted = false


      @data.each do |key,val|
        _add_access_method(key,val)
      end
    end

    def method_missing(sym, *args)

      if sym.to_s.end_with?("=")
        val = args[0]
        key = sym[0...sym.length-1].to_sym

        if val.nil?
          raise NoMethodError, "undefined method `#{sym}' for #{self.class.name}"
        else
          @data[key] = val
          _add_access_method(key, val)
        end

        @dirty = true
        return val
      end

      return @data[sym] if @data.include?(sym)

      raise NoMethodError, "undefined method `#{sym}' for #{self.class.name}"
    end

    def save!(force=false)
      raise SavingDeleted, "Trying to save a deleted object" if @deleted
      return true if !@dirty && !force

      db = self.class.wholedata

      if !@cached
        @orig = @data.dup
        db << @orig
      end

      @cached = true

      @orig.clear()
      @orig.update(@data)


      if self.class.save(db)
        @dirty = false
        return true
      else
        return false
      end
    end

    def delete
       @deleted = true
       return true if !@dirty && !@cached

       if @cached
         db = self.class.wholedata

         db.delete_if do |obj|
           obj.equal?(@orig)
         end

         @orig = nil

         self.class.save(db)
       end
    end


    protected
    def _add_access_method(key,val)
        self.class.define_method("#{key}=".to_sym) do |v|
          if v.nil?
            @data.delete(key)
            _remove_access_method(key)
          else
            @data[key] = v
          end

          @dirty = true
        end

        self.class.define_method("#{key}".to_sym) do
          @data[key]
        end
    end

    def _remove_access_method(key)
      begin
        self.class.remove_method(key.to_sym)
        self.class.remove_method("#{key}=".to_sym)
      rescue
      end
    end
  end

end
