import web3 from './web3';
import CampaignFactory from './build/CampaignFactory.json';

const instance = new web3.eth.Contract(
  (CampaignFactory.abi),
  '0xa1DAa872C3992FFb9cEAe5543Dd6840487E9f3E9'
);

export default instance;
