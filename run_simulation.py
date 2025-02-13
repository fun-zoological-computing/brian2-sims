from simulations.liquid_state_machine import liquid_state_machine
from simulations.sleep_normalization import sleep_normalization
from simulations.fp8_potjans_diesmann import fp8_potjans_diesmann
from simulations.neuron_synapse_models import neuron_synapse_models
from simulations.stdp import stdp
from simulations.balanced_network import balanced_network

import os
from datetime import datetime
import argparse
from brian2 import DEFAULT_FUNCTIONS, prefs, set_device, ms

from core.utils.misc import stochastic_decay, fp8_multiply, fp8_add,\
    fp8_smaller_than, deterministic_decay
DEFAULT_FUNCTIONS.update({'stochastic_decay': stochastic_decay,
                          'fp8_multiply': fp8_multiply,
                          'fp8_add': fp8_add,
                          'fp8_smaller_than': fp8_smaller_than,
                          'deterministic_decay': deterministic_decay})


parser = argparse.ArgumentParser(
    description='Main file that executes specified simulation',
    formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('--save_path',
                    type=str,
                    default=f"""{datetime.now().strftime('%Y.%m.%d')}"""
                            f"""_{datetime.now().hour}."""
                            f"""{datetime.now().minute}/""",
                    help=f'directory to save, creating folder and overwriting '
                         f'existing ones. Defaults to datetime name.')
parser.add_argument('--code_path',
                    type=str,
                    default='./code/',
                    help='directory of compiled code')
parser.add_argument('--quiet',
                    action='store_true',
                    help='whether to create plots/info or not')
parser.add_argument('--backend',
                    type=str,
                    default='numpy',
                    help='Backend used by brian2 to run simulation')
parser.add_argument('--timestep',
                    default=1,
                    type=float,
                    help='timestep of the simulation (dt), in ms')

subparsers = parser.add_subparsers(title='Simulation files available',
                                   help='Additional help for each available')

subparser_lsm = subparsers.add_parser(
    'LSM',
    formatter_class=argparse.ArgumentDefaultsHelpFormatter)
subparser_lsm.add_argument('--size',
                           type=int,
                           default=128,
                           help='size of the liquid')
subparser_lsm.add_argument('--trial',
                           type=int,
                           default=0,
                           help='trial number')
subparser_lsm.add_argument('--precision',
                           type=str,
                           default='fp64',
                           help=f'Bit precision used. Currently only supports '
                                f'8 and 64')
subparser_lsm.set_defaults(func=liquid_state_machine)

subparser_sleep = subparsers.add_parser(
    'sleep',
    formatter_class=argparse.ArgumentDefaultsHelpFormatter)
subparser_sleep.add_argument('--size',
                             type=int,
                             default=128,
                             help='size of the liquid')
subparser_sleep.add_argument('--trial',
                             type=int,
                             default=0,
                             help='trial number')
subparser_sleep.add_argument('--precision',
                             type=str,
                             default='fp64',
                             help=f'Bit precision used. Currently only '
                                  f'supports 8 and 64')
subparser_sleep.set_defaults(func=sleep_normalization)

subparser_pd = subparsers.add_parser(
    'PD',
    formatter_class=argparse.ArgumentDefaultsHelpFormatter)
subparser_pd.add_argument('--protocol',
                          type=int,
                          help=f'Type of stimulation. 1 is for spontaneous '
                               f'input whereas 2 is for thalamic')
subparser_pd.add_argument('--w_in',
                          type=float,
                          help=f'Relative strength of weights.')
subparser_pd.add_argument('--bg_freq',
                          type=float,
                          help=f'Strength of background noise, in Hz.')
subparser_pd.set_defaults(func=fp8_potjans_diesmann)

subparser_models = subparsers.add_parser(
    'models',
    formatter_class=argparse.ArgumentDefaultsHelpFormatter)
subparser_models.set_defaults(func=neuron_synapse_models)

subparser_balance = subparsers.add_parser(
    'balance',
    formatter_class=argparse.ArgumentDefaultsHelpFormatter)
subparser_balance.add_argument('--w_perc',
                               type=float,
                               help=f'Relative strength of weights. In the '
                                    f'case of minifloat, it represents '
                                    f'decimal value.')
subparser_balance.add_argument('--trial',
                               type=int,
                               default=0,
                               help='trial number')
subparser_balance.set_defaults(func=balanced_network)

subparser_stdp = subparsers.add_parser(
    'STDP',
    formatter_class=argparse.ArgumentDefaultsHelpFormatter)
subparser_stdp.set_defaults(func=stdp)

args = parser.parse_args()

os.makedirs(args.save_path, exist_ok=True)

if args.backend == 'numpy':
    prefs.codegen.target = args.backend
elif args.backend == 'cpp_standalone':
    set_device(args.backend, build_on_run=False)
elif args.backend == 'markdown':
    set_device(args.backend, filename='model_description')
else:
    raise UserWarning('Backend not supported')

args.func(args)
