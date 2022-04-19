#!/usr/bin/env python3
import click
import boto3
import botocore

client = boto3.client('ec2')

@click.group()
@click.option('--debug/--no-debug', default=False)
@click.pass_context
def kancli(ctx, debug):
    click.echo('Welcome to kancli')
    ctx.obj['DEBUG'] = debug


@kancli.command()
@click.pass_context
@click.option('-i', '--instance-id', 'custom_instance_id', required=False, type=str, help="instance to view")
def get_instances(ctx, custom_instance_id):
    click.echo('I\'m going to get instancs. Debug mode is  %s' %
               ('on' if ctx.obj['DEBUG'] else 'off'))
    #my_instances = client.describe_instances()
    my_instances = client.describe_instances(
    Filters=[
        {
            'Name': 'instance-state-code',
            'Values': [
            "0","16","64","80"
            ]
            }
        ]
    )
    Instances = []
    for reservation in my_instances['Reservations']:
        for instance in reservation['Instances']:
            instance_json = {
                'Id' : instance['InstanceId'],
                'State' : instance['State']['Name'],
            }
            Instances.append(instance_json)
            instancesDict = {"Instances": Instances}
    click.echo(instancesDict)


@kancli.command()
@click.pass_context
@click.option('-i', '--instance-id', 'custom_instance_id', required=True, type=str, help="instance id to stop")
def stop_instances(ctx, custom_instance_id):
    """Command to stop instances in AWS"""
    click.echo('I\'m going to stop instance/s {} .'.format(custom_instance_id))
    stop = click.confirm('Are you sure?????')
    if stop:
        click.echo("{} stopping now".format(custom_instance_id))
        client.stop_instances(InstanceIds=[custom_instance_id])
    else:
        click.echo("{} is safe for now".format(custom_instance_id))


@kancli.command()
@click.pass_context
@click.option('-i', '--instance-id', 'custom_instance_id', required=True, type=str, help="instance id to start")
def start_instances(ctx, custom_instance_id):
    """Command to start instances in AWS"""
    click.echo("{} will be up soon".format(custom_instance_id))
    client.start_instances(InstanceIds=[custom_instance_id])

@kancli.command()
@click.pass_context
@click.option('-i', '--instance-id', 'custom_instance_id', required=True, type=str, help="instance id to destroy")
def terminate_instances(ctx, custom_instance_id):
    """Command to stop instances in AWS"""
    click.echo('I\'m going to stop instance/s {} .'.format(custom_instance_id))
    stop = click.confirm('Are you sure?????')
    if stop:
        click.echo("{} destroying now".format(custom_instance_id))
        client.terminate_instances(InstanceIds=[custom_instance_id])
    else:
        click.echo("{} is safe for now".format(custom_instance_id))

if __name__ == '__main__':
    kancli(obj={})
