class Transaction

  include Mongoid::Document
  include Mongoid::Timestamps  
  
  field :bus_op, type: Symbol
  field :amount, type: Integer
  field :currency, type: Symbol
  field :desc, type: String
  
  belongs_to :transaction_account
  
  def self.add(amount: nil, bus_op: nil, desc: nil)
    txn = self.new.send(bus_op, amount: amount, desc: desc)
    txn
  end
  
  def withdraw(amount: nil, desc: nil)
    self.amount = amount
    self.bus_op = :withdraw
    self.desc = desc    
    self.save
    self
  end
  
  def deposit(amount: nil, desc: nil)
    self.amount = amount
    self.bus_op = :deposit
    self.desc = desc
    self.save
    self
  end
  
end
