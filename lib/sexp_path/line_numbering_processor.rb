require 'parse_tree' rescue nil

# Processes a Sexp, keeping track of newlines, 
class LineNumberingProcessor < SexpProcessor
  # Helper method for generating a Sexp with line numbers.
  #
  # Only available if ParseTree is loaded.
  def self.process_file(path)
    raise 'ParseTree must be installed.' unless Object.const_defined? :ParseTree
    
    code = File.read(path)
    sexp = Sexp.from_array(ParseTree.new(true).parse_tree_for_string(code, path).first)
    processor = LineNumberingProcessor.new
    processor.rewrite sexp
  end
  
  def initialize()
    super
    self.auto_shift_type = true
    @unsupported.delete :newline
    
    @file = ''
    @line = 0
  end
  
  def rewrite exp
    #sexp = Sexp.from_array(exp) unless Sexp === exp or exp.nil?
    unless exp.nil?
      exp.file = @file
      exp.line = @line
    end
    
    
    super exp
  end
  
  #s(:newline, 21, "test/sample.rb", s(:call, nil, :private, s(:arglist)) )
  def rewrite_newline(exp)
    type = exp.shift
    @line = exp.shift
    @file = exp.shift
    sexp = exp.shift
    
    rewrite(sexp)
  end
end