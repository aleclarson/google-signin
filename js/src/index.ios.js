var type;

type = Type("GoogleSignIn");

type.defineMethods({
  signIn: function() {}
});

module.exports = type.construct();
