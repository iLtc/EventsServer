class SyncWorker
  include Sidekiq::Worker

  def perform()
    logger = Logger.new(STDOUT)

    logger.info "SyncWorker begin at " + DateTime.now.to_s

    Uiowa.sync
    IowaCity.sync

    SyncWorker.perform_in(6.hours)
  end
end
