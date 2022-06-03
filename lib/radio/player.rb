# frozen_string_literal: true

class Radio
  class Player
    attr_accessor :backend, :pid, :thr

    def initialize(backend = 'cvlc')
      @backend = backend
      @pid = nil
      @thr = nil
    end

    def alive?
      return false if @thr.nil?

      @thr.alive?
    end

    def stop?
      @thr.nil? || @thr.stop?
    end

    def play(url)
      @pid = spawn("#{backend} #{url}")
      @thr = Process.detach(@pid)
    end

    def stop
      return unless alive?

      r = Process.kill(:TERM, pid)
      @thr = nil
      @pid = nil
      r
    end
  end
end
