class Transaction

  include Mongoid::Document
  include Mongoid::Timestamps  
  
  include UrlHelpers
  
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
  
  def txn_event
    {
      event: "txn_event",
      timestamps: {
        transaction_time: self.created_at
      },
      transaction: {
        bus_op: self.bus_op,
        amount: self.amount,
        desc: self.desc
      },
      party: {
        _links: {
          self: {
            href: self.transaction_account.party_url
          }
        }
      },
      account: {
        type: self.transaction_account.type,
        _links: {
          self: {
            href: url_helpers.api_v1_account_url(self.transaction_account, host: Setting.services(:self, :host))
          }
        }        
      }     
    }
  end
  
end