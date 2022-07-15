defmodule Auth do

  def hashPassword(password) do
    Pbkdf2.hash_pwd_salt(password)
  end

  def verifyPassword?(password, storedHash) do
    Pbkdf2.verify_pass(password, storedHash)
  end
end
