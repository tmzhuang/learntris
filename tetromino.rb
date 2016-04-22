#!/usr/bin/env ruby
class Tetromino
	require "sqlite3"
	require_relative "point"
	attr_accessor :type, :color, :size, :loc

	DATABASE_NAME = "tetromino.db"
	TABLE_NAME = "tetromino"
	@@db = SQLite3::Database.open(DATABASE_NAME)
	@@types = @@db.execute("select tet_type from " + TABLE_NAME).flatten

	def initialize(board, loc = nil, type)
		@board = board
		@type = type
		@color = db_query("tet_color")
		@size = db_query("tet_size")

		loc ||= [0, (board.width - @size) / 2]
		@loc = loc

		# db_query returns a string and we want the actual array
		@points = eval(db_query("tet_points"))
		@@db.close
	end

	def db_query(attr)
		# SELECT attr from TABLE_NAME where tet_type = @type
		# Return is a doubly nested array, which is why we call first twice
		@@db.execute("select " + attr + " from " + TABLE_NAME + " where tet_type = ?", @type).first.first
	end

	def self.db
		@@db
	end

	def self.types
		@@types
	end

	def points
		result = @points.map do |x,y|
			x += loc.first
			y += loc.last
		end
	end

	def to_s
		ary = Array.new(@size) { Array.new(@size, '.')}
		s = ""

		@points.each do |x,y|
			ary[x][y] = @color
		end

		ary.each do |row|
			row.each_with_index do |c, index|
				if index != 0
					s += ' '
				end
				s += c
			end
			s += "\n"
		end
		s
	end

	def rotate(dir=:right)
		# Pivot point (o for origin)
		o = Array.new(2, (@size - 1) / 2.0)

		# Get points in reference to o (d for difference)
		d = @points.map do |p| [p.first - o.first , p.last - o.last] end

		# Do rotation
		r = []
		d.each do |x,y|
			case dir
			when :right
				r.push [y, -x]
			when :left
				r.push [-y, x]
			end
		end

		r = to_table_coords(r)

		# Convert points back to original reference
		@points = r.map do |p| [p.first + o.first, p.last + o.last] end
	end

	def to_table_coords(points)
		result = []
		points.each do |x,y|
			result.push [x + @loc.first, y + @loc.last]
		end
		return result
	end

	if __FILE__ == $0
		t = Tetromino.new("I")
		puts t.to_s
		t.rotate
		puts t.to_s
		t.rotate
		puts t.to_s
		t.rotate
		puts t.to_s
		t = Tetromino.new("S")
		puts t.to_s
		t.rotate
		puts t.to_s
		t.rotate
		puts t.to_s
		t.rotate
		puts t.to_s

	end
end
