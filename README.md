# Erlang NIF C libsecp256k1

============

Bindings for most of the library functionality
Tested with Erlang/OTP 17+

Installation
------------
If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `libsecp256k1` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:libsecp256k1, "~> 0.1.9"}]
end
```

Build and usage steps
---------------------
	$ mix compile
	$ erl -pa _build/dev/lib/libsecp256k1/ebin/
	  Privkey = crypto:strong_rand_bytes(32).
	  {ok, Pubkey} = libsecp256k1:ec_pubkey_create(Privkey, compressed).

Testing
-------
  $ mix eunit

Debugging
---------

Library should be statically compiled.
