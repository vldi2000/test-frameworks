module.exports = {
  before : function(browser) {
    console.log('Setting up...');
  },
  after : function(browser) {
    console.log('Closing down...');
  },
  beforeEach : function(browser) {

  },
  afterEach : function() {

  },
  'Google\'s Search Functionality' : function (browser) {
    browser
      .url('https://www.google.com/ncr')
      .waitForElementVisible('body', 1000)
      .setValue('input[type=text]', 'BrowserStack\n')
      .pause(1000)
      .assert.title('BrowserStac - Google Search')
      .end();
  }
};
