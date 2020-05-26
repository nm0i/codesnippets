#!/usr/bin/python3
import asyncio
import aiohttp
import xmltodict
import html2text
import re

class Config():
    def __init__(self):
        # Discord related stuff below
        # Do view these enable dev settings in discord and right click on stuff.
        # Most of these are probably no longer required
        self.name = "Cool Bot Name"
        self.channel_id = ""
        self.token = ""
        self.avatar = ""
        # Your server id. Guild is just an old name discord used to use.
        self.guild_id = ""
        self._id = ""
        self.webhook_url = ""

        # RSS related stuff below
        # Feed URL
        self.feed_url = ""

def crop(doc, start, end):
    return doc[start:end]

async def get_feed_from_rss(session, url):
    async with session.get(url) as rss_response:
        feed = await rss_response.text()
        return xmltodict.parse(feed, process_namespaces=True)

async def send_news_via_discord(session, url, data):
    await session.post(url, json=data)

async def main():
    # Where we story info on posts?
    last_package = open("posts.lst","r")
    lines =  last_package.readlines()
    lines = [line.rstrip('\n') for line in lines]
    last_package.close()
    last_package = open("posts.lst","w")
    h = html2text.HTML2Text()
    h.ignore_links = True
    config = Config()
    async with aiohttp.ClientSession() as session:
        feed = await get_feed_from_rss(session, config.feed_url)
        # Feed parsing goes below. Adjust according to your feed.
        # This example uses dokuwiki atom-formatted feed.
        # This is essentially a dictionary with structure that depends on your feed.
        feed = feed["http://purl.org/atom/ns#:feed"]["http://purl.org/atom/ns#:entry"]
        for news in feed:
            post = "```\n"
            post = post + news["http://purl.org/atom/ns#:author"]["http://purl.org/atom/ns#:name"] + "->"
            post = post + news["http://purl.org/atom/ns#:title"] + "\n"
            contents = h.handle(news["http://purl.org/atom/ns#:summary"])
            contents = re.sub("\* \* \*\n","",contents)
            contents = re.sub("\n\n","\n",contents)
            contents = re.sub("Statistics.*\n","",contents)
            post = post + contents[0:64] +"...```\n"
            post = post + news["http://purl.org/atom/ns#:id"]
            if not news["http://purl.org/atom/ns#:id"] in lines:
                data = {
                    "content": (post),
                    "name": config.name,
                    "avatar": config.avatar,
                    "channel_id": config.channel_id,
                    "guild_id": config.guild_id,
                    "id": config._id,
                    "token": config.token
                }
                #Instead of sending it to discord you can print it here for testing purposes
                # print("hello")
                await send_news_via_discord(session, config.webhook_url, data)
            last_package.write(news["http://purl.org/atom/ns#:id"]+"\n")
    last_package.close()

loop = asyncio.get_event_loop()
loop.run_until_complete(main())
